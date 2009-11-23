use MooseX::Declare;

class AnyEvent::Inotify::EventReceiver::Debug with AnyEvent::Inotify::EventReceiver {
    use Carp qw(carp);
    use MooseX::Types::Path::Class qw(File Dir);

    method handle_access(File|Dir $file) {
        carp "Access $file";
    }

    method handle_modify(File|Dir $file) {
        carp "Modify $file";
    }

    method handle_attribute_change(File|Dir $file) {
        carp "Attribute change $file";
    }

    method handle_close(File|Dir $file) {
        carp "Close $file";
    }

    method handle_open(File|Dir $file) {
        carp "Open $file";
    }

    method handle_move(File|Dir $from, File|Dir $to) {
        carp "Move $from to $to";
    }

    method handle_delete(File|Dir $file) {
        carp "Delete $file";
    }

    method handle_create(File|Dir $file) {
        carp "Create $file";
    }
}
