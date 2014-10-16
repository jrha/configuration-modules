#!/usr/bin/perl
# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use Test::MockModule;
use Test::Quattor;
use NCM::Component::metaconfig;
use CAF::Object;
use Cwd;

use Template;

use Readonly;

$CAF::Object::NoAction = 1;

my $mock = Test::MockModule->new('CAF::TextRender');
$mock->mock('new', sub {
    my $init = $mock->original("new");
    my $trd = &$init(@_);
    $trd->{includepath} = getcwd()."/src/test/resources";
    $trd->{relpath} = 'rendertest';
    return $trd;
});


=pod

=head1 DESCRIPTION

Test that a config file can be generated by this component, using
Template::Toolkit to render an arbitrary file format.

=head1 TESTS

=cut


my $cmp = NCM::Component::metaconfig->new('metaconfig');

my $cfg = {
	   contents => {
			foo => 1,
			bar => 2,
			baz => {
				a => [0..3]
				}
			},
	   module => "foo/bar",
	  };

=pod

=head2 Basic method execution

All methods are called with the expected arguments.

=cut

$cmp->handle_service("/foo/bar", $cfg);

my $fh = get_file("/foo/bar");
isa_ok($fh, "CAF::FileWriter", "Correct class");
is("$fh", "1 2 0:1:2:3\n", "Rendered correctly");

=pod

=head2 Errors while rendering the template are reported

Also, the error string generated by C<Template::Toolkit> must be
displayed

=cut

$cmp->{ERROR} = 0;

$cfg->{module} = 'test_broken';
$cmp->handle_service("/foo/bar2", $cfg);
is($cmp->{ERROR}, 3, "3 errors reported when the template processing fails");
$fh = get_file("/foo/bar2");
ok(!defined($fh), "Render failure, no output file");

=pod

=head2 Errors when sanitizing the template are reported

=cut

$cfg->{module} = "invalid";
$cmp->{ERROR} = 0;
$cmp->handle_service("/foo/bar3", $cfg);
is($cmp->{ERROR}, 3, "3 errors reported when the module doesn't exists");
$fh = get_file("/foo/bar3");
ok(!defined($fh), "Non-existing module, no output file");


done_testing();
