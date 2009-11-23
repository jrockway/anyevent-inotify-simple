use MooseX::Declare;

class AnyEvent::Inotify::EventReceiver::Null with AnyEvent::Inotify::EventReceiver {
    method handle_access {}
    method handle_modify {}
    method handle_attribute_change {}
    method handle_close {}
    method handle_open {}
    method handle_move {}
    method handle_delete {}
    method handle_create {}
}
