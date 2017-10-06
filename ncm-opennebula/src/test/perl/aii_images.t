#!/usr/bin/perl 
# -*- mode: cperl -*-
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

use strict;
use warnings;
use Test::More;
use Test::MockModule;
use Test::Quattor qw(aii_images);
use OpennebulaMock;
use NCM::Component::opennebula;

my $cfg = get_config_for_profile('aii_images');
my $opennebulaaii = new Test::MockModule('NCM::Component::OpenNebula::AII');
$opennebulaaii->mock('read_one_aii_conf', Net::OpenNebula->new(url  => "http://localhost/RPC2",
                                                      user => "oneadmin",));
$opennebulaaii->mock('is_timeout', undef);

my $aii = NCM::Component::opennebula->new();

my $ttout = $aii->process_template_aii($cfg, "imagetemplate");

like($ttout, qr{^DATASTORE\s+=\s+}m, "Found DATASTORE");

my %images = $aii->get_images($cfg);

my $imagea = "node630.cubone.os_vda";
my $imageb = "node630.cubone.os_vdb";

ok(exists($images{$imagea}), "image a exists");
ok(exists($images{$imageb}), "image b exists");

is($images{$imagea}{datastore}, "ceph.altaria", "datastore of image a is ceph.altaria");
is($images{$imageb}{datastore}, "ceph.altaria", "datastore of image b is ceph.altaria");

like($images{$imagea}{image}, qr{^TARGET\s+=\s+"vda"\s*$}m, "image a contains TARGET vda");
like($images{$imageb}{image}, qr{^TARGET\s+=\s+"vdb"\s*$}m, "image b contains TARGET vdb");

my $one = $aii->read_one_aii_conf();

# Check image creation
rpc_history_reset;
$aii->remove_or_create_vm_images($one, 1, \%images);
#diag_rpc_history;
ok(rpc_history_ok(["one.imagepool.info",
                   "one.imagepool.info",
                   "one.datastorepool.info",
                   "one.image.allocate",
                   "one.image.info"]),
                   "remove_or_create_vm_images install rpc history ok");

# Check image remove
rpc_history_reset;
$aii->remove_or_create_vm_images($one, undef, \%images, undef, 1);
#diag_rpc_history;
ok(rpc_history_ok(["one.imagepool.info",
                   "one.image.delete"]),
                   "remove_or_create_vm_images remove rpc history ok");

done_testing();
