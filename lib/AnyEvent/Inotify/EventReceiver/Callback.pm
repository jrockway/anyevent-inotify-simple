package AnyEvent::Inotify::EventReceiver::Callback;
use Moose;
#use namespace::autoclean;

use MooseX::Types::Moose qw(CodeRef);

has 'callback' => (
    is       => 'ro',
    isa      => CodeRef,
    required => 1,
);

for my $event (qw/access modify attribute_change close open move delete create/){
    __PACKAGE__->meta->add_method( "handle_$event" => sub {
        my $self = shift;
        $self->callback->($event, @_);
    });
}

with 'AnyEvent::Inotify::EventReceiver';

1;
