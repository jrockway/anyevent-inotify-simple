use inc::Module::Install;
use strict;

name 'AnyEvent-Inotify-Simple';
all_from 'lib/AnyEvent/Inotify/Simple.pm';

requires 'MooseX::Declare';
requires 'AnyEvent';
requires 'Linux::Inotify2';
requires 'File::Next';
requires 'MooseX::Types::Path::Class';
requires 'MooseX::FileAttributes';
requires 'Path::Filter';

test_requires 'Test::More';
test_requires 'EV';

WriteAll;
