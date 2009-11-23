use MooseX::Declare;

role AnyEvent::Inotify::EventReceiver {
    requires 'handle_access';
    requires 'handle_modify';
    requires 'handle_attribute_change';
    requires 'handle_close';
    requires 'handle_open';
    requires 'handle_move';
    requires 'handle_delete';
    requires 'handle_create';

    method handle_close_write ($f) {
        $self->handle_close($f);
    }

    method handle_close_nowrite ($f) {
        $self->handle_close($f);
    }

    # requires 'handle_close_write';
    # requires 'handle_close_nowrite';
}
