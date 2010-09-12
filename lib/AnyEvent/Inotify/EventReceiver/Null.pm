package AnyEvent::Inotify::EventReceiver::Null;
use Moose;
use namespace::autoclean;

with 'AnyEvent::Inotify::EventReceiver';

sub handle_access {}
sub handle_modify {}
sub handle_attribute_change {}
sub handle_close {}
sub handle_open {}
sub handle_move {}
sub handle_delete {}
sub handle_create {}

1;
