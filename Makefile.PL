use inc::Module::Install;
use strict;

name 'AnyEvent-Inotify-Simple';
all_from 'lib/AnyEvent/Inotify/Simple.pm';

requires 'AnyEvent';
requires 'File::Next';
requires 'Linux::Inotify2';
requires 'MooseX::FileAttribute';
requires 'MooseX::Types::Path::Class';
requires 'Moose';

test_requires 'Directory::Scratch';
test_requires 'EV';
test_requires 'MooseX::Declare'; # I'm lazy.
test_requires 'Test::More';
test_requires 'Test::Sweet';
test_requires 'Test::Exception';

WriteAll;
