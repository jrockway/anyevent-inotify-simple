package AnyEvent::Inotify::EventReceiver;
use Moose::Role;

requires 'handle_access';
requires 'handle_modify';
requires 'handle_attribute_change';
requires 'handle_close';
requires 'handle_open';
requires 'handle_move';
requires 'handle_delete';
requires 'handle_create';

sub handle_close_write  {
    my ($self, $f) = @_;
    $self->handle_close($f);
}

sub handle_close_nowrite  {
    my ($self, $f) = @_;
    $self->handle_close($f);
}

# requires 'handle_close_write';
# requires 'handle_close_nowrite';

1;
