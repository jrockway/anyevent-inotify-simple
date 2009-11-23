use strict;
use warnings;
use Test::More tests => 3;

use ok 'AnyEvent::Inotify::Simple';

use Directory::Scratch;

my $tmp = Directory::Scratch->new;

my $done = AnyEvent->condvar;

my @created;
my $w = AnyEvent::Inotify::Simple->new(
    directory      => $tmp->base,
    event_receiver => sub {
        my ($type, $file) = @_;
        return unless $type eq 'create';

        push @created, $file->relative($tmp->base)->stringify;
        $done->end;
    }
);

ok $w, 'got watcher';

sub op($$;@) {
    my $op = shift;
    $done->begin;
    $tmp->$op(@_);
}

{
    $done->begin;

    op 'touch', 'foo';
    op 'mkdir', 'dir';
    $w->inotify->poll;
    op 'mkdir', 'dir/subdir';
    $w->inotify->poll;
    op 'touch', 'dir/subdir/thing';
    op 'touch', 'dir/thing_in_here';
    op 'touch', 'bar';

    $done->end;
}

$done->recv;

is_deeply [@created],
  [qw{foo dir dir/subdir dir/subdir/thing dir/thing_in_here bar}],
  'got correct list of created files';
