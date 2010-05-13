use MooseX::Declare;

class AnyEvent::Inotify::Simple {
    use MooseX::FileAttribute;
    use MooseX::Types::Path::Class qw(File Dir);
    use MooseX::Types::Moose qw(RegexpRef HashRef CodeRef);
    use MooseX::Types -declare => ['Receiver'];

    use AnyEvent::Inotify::EventReceiver;
    use AnyEvent::Inotify::EventReceiver::Callback;

    role_type Receiver, { role => 'AnyEvent::Inotify::EventReceiver' };

    coerce Receiver, from CodeRef, via {
        AnyEvent::Inotify::EventReceiver::Callback->new(
            callback => $_,
        ),
    };

    use AnyEvent;
    use Linux::Inotify2;
    use File::Next;
    use Path::Filter;

    has_directory 'directory' => ( must_exist => 1, required => 1);

    has 'filter' => (
        is       => 'ro',
        isa      => 'Path::Filter',
        lazy     => 1,
        default  => sub {
            my $self = shift;
            return Path::Filter->new(
                rules => [qw/Backup VersionControl EditorJunk/],
                root  => $self->directory,
            );
        },
        handles  => {
            is_filtered => 'filter',
        },
    );

    has 'event_receiver' => (
        is       => 'ro',
        isa      => Receiver,
        handles  => 'AnyEvent::Inotify::EventReceiver',
        required => 1,
        coerce   => 1,
    );

    has 'inotify' => (
        init_arg   => undef,
        is         => 'ro',
        isa        => 'Linux::Inotify2',
        handles    => [qw/poll fileno watch/],
        lazy_build => 1,
    );

    method _build_inotify {
        Linux::Inotify2->new or confess "Inotify initialization failed: $!";
    }

    has 'io_watcher' => (
        init_arg => undef,
        is       => 'ro',
        builder  => '_build_io_watcher',
        required => 1,
    );

    method _build_io_watcher {
        return AnyEvent->io(
            fh   => $self->fileno,
            poll => 'r',
            cb   => sub { $self->poll },
        );
    }

    has 'cookie_jar' => (
        init_arg => undef,
        is       => 'ro',
        isa      => HashRef,
        required => 1,
        default  => sub { +{} },
    );

    method _watch_directory(Dir $dir){
        my $next = File::Next::dirs({
            follow_symlinks => 0,
        }, $dir);

        while ( my $entry = $next->() ) {
            last unless defined $entry;
            next if $self->is_filtered($entry);

            if( -d $entry ){
                $entry = Path::Class::dir($entry);
            }
            else {
                $entry = Path::Class::file($entry);
            }

            $self->watch(
                $entry->stringify,
                IN_ALL_EVENTS,
                sub { $self->handle_event($entry, $_[0]) },
            );
        }
    }

    method BUILD {
        $self->_watch_directory($self->directory->resolve->absolute);
    }

    my %events = (
        IN_ACCESS        => 'handle_access',
        IN_MODIFY        => 'handle_modify',
        IN_ATTRIB        => 'handle_attribute_change',
        IN_CLOSE_WRITE   => 'handle_close_write',
        IN_CLOSE_NOWRITE => 'handle_close_nowrite',
        IN_OPEN          => 'handle_open',
        IN_CREATE        => 'handle_create',
        IN_DELETE        => 'handle_delete',
    );

    method handle_event(Dir $file, Object $event) {
        my $wrapper = $event->IN_ISDIR ? 'subdir' : 'file';
        my $event_file = $file->$wrapper($event->name);

        if( $event->IN_DELETE_SELF || $event->IN_MOVE_SELF ){
            #warn "canceling $file";
            #$event->w->cancel;
            return;
        }

        if($self->is_filtered($event_file)){
            # we get this when a directory watcher notices something
            # about a file that should be ignored
            return;
        }

        my $relative = $event_file->relative($self->directory);
        my $handled = 0;

        for my $type (keys %events){
            my $method = $events{$type};
            if( $event->$type ){
                $self->$method($relative);
                $handled = 1;
            }
        }

        if( $event->IN_MOVED_FROM ){
            $self->handle_move_from($relative, $event->cookie);
            $handled = 1;
        }

        if( $event->IN_MOVED_TO ){
            $self->handle_move_to($relative, $event->cookie);
            $handled = 1;
        }

        if (!$handled){
            require Data::Dump::Streamer;
            Carp::cluck "BUGBUG: Unhandled event: ".
                Data::Dump::Streamer->Dump($event)->Out;
        }

    }

    method rel2abs(File|Dir $file){
        return $file if $file->is_absolute;
        return $file->absolute($self->directory)->resolve->absolute;
    }

    method handle_move_from(File|Dir $file, Int $cookie){
        $self->cookie_jar->{from}{$cookie} = $file;
    }

    method handle_move_to(File|Dir $to, Int $cookie){
        my $from = delete $self->cookie_jar->{from}{$cookie};
        confess "Invalid move cookie '$cookie' (moved to '$to')"
          unless $from;

        my $abs = $self->rel2abs($to);
        $self->_watch_directory($abs) if -d $abs;

        $self->handle_move($from, $to);
    }

    # inject our magic
    before handle_create(File|Dir $dir){
        my $abs = $self->rel2abs($dir);
        return unless -d $abs;
        $self->_watch_directory($abs);
    }

    method DEMOLISH {
        for my $w (values %{$self->inotify->{w}}){
            $w->cancel;
        }
    }
}
