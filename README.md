# NAME

AnyEvent::Inotify::Simple - monitor a directory tree in a non-blocking way

# SYNOPSIS

    use AnyEvent::Inotify::Simple;
    use EV; # or POE, or Event, or ...

    my $inotify = AnyEvent::Inotify::Simple->new(
        directory      => '/tmp/uploads/',
        wanted_events  => [ qw(create move) ],
        event_receiver => sub {
            my ($event, $file, $moved_to) = @_;
            given($event) {
                when('create'){
                   say "Someone just uploaded $file!"
                }
            };
        },
    );

    EV::loop;

# DESCRIPTION

This module is a wrapper around [Linux::Inotify2](https://metacpan.org/pod/Linux%3A%3AInotify2) that integrates it
with an [AnyEvent](https://metacpan.org/pod/AnyEvent) event loop and makes monitoring a directory
simple.  Provide it with a `directory`, `event_receiver`
([AnyEvent::Inotify::Simple::EventReceiver](https://metacpan.org/pod/AnyEvent%3A%3AInotify%3A%3ASimple%3A%3AEventReceiver)), and an optional coderef
`filter` and/or optional array ref `wanted_events`, and it will
monitor an entire directory tree.  If something
is added, it will start watching it.  If something goes away, it will
stop watching it.  It also converts `IN_MOVE_FROM` and `IN_MOVE_TO`
into one virtual event.

Someday I will write more, but that's really all that happens!

# METHODS

None!  Create the object, and it starts working immediately.  Destroy
the object, and the inotify state and watchers are automatically
cleaned up.

# REPOSITORY

Forks welcome!

[http://github.com/jrockway/anyevent-inotify-simple](http://github.com/jrockway/anyevent-inotify-simple)

# AUTHOR

Jonathan Rockway `<jrockway@cpan.org>`

Current maintainer is Rob N ★ `<robn@robn.io>`

# COPYRIGHT

Copyright 2009 (c) Jonathan Rockway.  This module is Free Software.
You may redistribute it under the same terms as Perl itself.
