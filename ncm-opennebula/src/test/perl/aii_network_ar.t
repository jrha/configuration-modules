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
use Test::Quattor qw(aii_network_ar);
use OpennebulaMock;
use NCM::Component::opennebula;

my $cfg = get_config_for_profile('aii_network_ar');
my $opennebulaaii = new Test::MockModule('NCM::Component::OpenNebula::AII');
$opennebulaaii->mock('read_one_aii_conf', Net::OpenNebula->new(url  => "http://localhost/RPC2",
                                                      user => "oneadmin",));

my $aii = NCM::Component::opennebula->new();

my $ttout = $aii->process_template_aii($cfg, "network_ar");

like($ttout, qr{^NETWORK\s+=\s+}m, "Found vnet NETWORK name");

my %networks = $aii->get_vnetars($cfg);

my $networka = "altaria.os";
my $networkb = "altaria.vsc";

ok(exists($networks{$networka}), "vnet a exists");
ok(exists($networks{$networkb}), "vnet b exists");

is($networks{$networka}{network}, "altaria.os", "vneta name is altaria.os");
is($networks{$networkb}{network}, "altaria.vsc", "vnetb name is altaria.vsc");

my $one = $aii->read_one_aii_conf();

diag("Check AR creation");

rpc_history_reset;
$aii->remove_and_create_vn_ars($one, \%networks, 0);
#diag_rpc_history;
ok(rpc_history_ok(["one.vnpool.info",
                   "one.vn.info",
                   "one.vnpool.info"]),
                   "remove_and_create_vn_ars install rpc history ok");

diag("Check AR remove");
rpc_history_reset;
$aii->remove_and_create_vn_ars($one, \%networks, 1);
#diag_rpc_history;
ok(rpc_history_ok(["one.vnpool.info",
                   "one.vn.rm_ar",
                   "one.vnpool.info"]),
                   "remove_and_create_vn_ars remove rpc history ok");

done_testing();
