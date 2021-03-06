# -*- mode: cperl -*-
# ${license-info}
# ${author-info}
# ${build-info}

use strict;
use warnings;

BEGIN {
  *CORE::GLOBAL::sleep = sub {};
}

use Test::More tests => 14;
use Test::NoWarnings;
use Test::Quattor qw(local-redir cms-fed-redir);
use NCM::Component::xrootd;
use Readonly;
use CAF::Object;
Test::NoWarnings::clear_warnings();

=pod

=head1 SYNOPSIS

Basic test for local redirector configuration

=cut

use constant REDIR_CONF_FILE => "/etc/xrootd/local-redir.cfg";

use constant REDIR_INITIAL_CONF => '#>>>>>>>>>>>>> Variable declarations

# Installation specific
set xrdlibdir = $XRDLIBDIR
set dpmhost = grid05.lal.in2p3.fr
# set xrootfedlport1 = $XROOT_FED_LOCAL_PORT_ATLAS
# set xrootfedlport2...
setenv DPNS_HOST = grid05.lal.in2p3.fr
setenv DPM_HOST = grid05.lal.in2p3.fr

#>>>>>>>>>>>>>

all.adminpath /var/spool/xrootd
all.pidpath /var/run/xrootd
#all.sitename <to_be_set>

xrd.network nodnr
xrootd.seclib libXrdSec.so
sec.protocol /usr/$(xrdlibdir) gsi -crl:3 -key:/etc/grid-security/dpmmgr/dpmkey.pem -cert:/etc/grid-security/dpmmgr/dpmcert.pem -md:sha256:sha1 -ca:2 -gmapopt:10 -vomsat:0
sec.protocol /usr/$(xrdlibdir) unix

ofs.cmslib libXrdDPMFinder.so.3
ofs.osslib libXrdDPMOss.so.3
ofs.authorize
ofs.forward all

dpm.xrdserverport 1095

# for any federations setup provide a reirect to federation handler
#xrootd.redirect $dpmhost:11001 /store/
#xrootd.redirect $dpmhost:11000 /atlas/

# the following can be used to check for and if necessary add a
# prefix to file names. i.e. to allow access via names like /dteam/the_file
dpm.defaultprefix /dpm/lal.in2p3.fr/home

ofs.trace all
xrd.trace all
cms.trace all
oss.trace all

xrootd.export /

all.role manager

# authorization; by default authorization is only up to the dpm
#
ofs.authlib libXrdDPMRedirAcc.so.3
#
# more advanced: the "secondary" authlib (if set) is an xrootd
# authorization library given as the argument to libXrdDPMRedirAcc.
# It is used as follows:
#
#   If no usable identity is available via the "sec.protocol" or if
# special tokens are found in the opaque data, a secondary authlib can
# be used to check and allow requests to be sent to the dpm on behalf
# of a fixed identity, set here.
#
# e.g. libXrdAliceTokenAcc
#
# setenv TTOKENAUTHZ_AUTHORIZATIONFILE=/etc/xrd.authz.cnf
ofs.authlib libXrdDPMRedirAcc.so.3
# dpm.replacementprefix /alice /dpm/example.com/home/alice
# dpm.fixedidrestrict /dpm/example.com/home/alice
#
# User must be listed in lcgdm-mapfile
# dpm.principal alicetoken
# dpm.fqan /alice

xrootd.monitor all rbuff 32k auth flush 30s window 5s dest files info user io redir atl-prod05.slac.stanford.edu:9930
xrd.report atl-prod05.slac.stanford.edu:9931 every 60s all -buff -poll sync

# vomsxrd: dpm.nohv1 else dpm.listvoms
dpm.listvoms
#dpm.nohv1
';

use constant REDIR_EXPECTED_CONF_1 => '# This file is managed by Quattor - DO NOT EDIT lines generated by Quattor
#
setenv DPM_HOST = grid05.lal.in2p3.fr
setenv DPNS_HOST = grid05.lal.in2p3.fr
all.sitename GRIF-LAL
dpm.defaultprefix /dpm/lal.in2p3.fr/home
dpm.nohv1
set dpmhost = grid05.lal.in2p3.fr
ofs.authlib libXrdDPMRedirAcc.so.3
sec.protocol /usr/$(xrdlibdir) gsi -ca:2 -cert:/etc/grid-security/dpmmgr/dpmcert.pem -crl:3 -gmapopt:10 -key:/etc/grid-security/dpmmgr/dpmkey.pem -md:sha256:sha1 -vomsfun:/usr/lib64/libXrdSecgsiVOMS.so
xrd.report atl-prod05.slac.stanford.edu:9931 every 60s all -buff -poll sync
xrootd.monitor all rbuff 32k auth flush 30s window 5s dest files info user io redir atl-prod05.slac.stanford.edu:9930
';

use constant REDIR_EXPECTED_CONF_2 => '# This file is managed by Quattor - DO NOT EDIT lines generated by Quattor
#
#>>>>>>>>>>>>> Variable declarations

# Installation specific
set xrdlibdir = $XRDLIBDIR
set dpmhost = grid05.lal.in2p3.fr
# set xrootfedlport1 = $XROOT_FED_LOCAL_PORT_ATLAS
# set xrootfedlport2...
setenv DPNS_HOST = grid05.lal.in2p3.fr
setenv DPM_HOST = grid05.lal.in2p3.fr

#>>>>>>>>>>>>>

all.adminpath /var/spool/xrootd
all.pidpath /var/run/xrootd
all.sitename GRIF-LAL

xrd.network nodnr
xrootd.seclib libXrdSec.so
sec.protocol /usr/$(xrdlibdir) gsi -ca:2 -cert:/etc/grid-security/dpmmgr/dpmcert.pem -crl:3 -gmapopt:10 -key:/etc/grid-security/dpmmgr/dpmkey.pem -md:sha256:sha1 -vomsfun:/usr/lib64/libXrdSecgsiVOMS.so
sec.protocol /usr/$(xrdlibdir) unix

ofs.cmslib libXrdDPMFinder.so.3
ofs.osslib libXrdDPMOss.so.3
ofs.authorize
ofs.forward all

dpm.xrdserverport 1095

# for any federations setup provide a reirect to federation handler
#xrootd.redirect $dpmhost:11001 /store/
#xrootd.redirect $dpmhost:11000 /atlas/

# the following can be used to check for and if necessary add a
# prefix to file names. i.e. to allow access via names like /dteam/the_file
dpm.defaultprefix /dpm/lal.in2p3.fr/home

ofs.trace all
xrd.trace all
cms.trace all
oss.trace all

xrootd.export /

all.role manager

# authorization; by default authorization is only up to the dpm
#
ofs.authlib libXrdDPMRedirAcc.so.3
#
# more advanced: the "secondary" authlib (if set) is an xrootd
# authorization library given as the argument to libXrdDPMRedirAcc.
# It is used as follows:
#
#   If no usable identity is available via the "sec.protocol" or if
# special tokens are found in the opaque data, a secondary authlib can
# be used to check and allow requests to be sent to the dpm on behalf
# of a fixed identity, set here.
#
# e.g. libXrdAliceTokenAcc
#
# setenv TTOKENAUTHZ_AUTHORIZATIONFILE=/etc/xrd.authz.cnf
ofs.authlib libXrdDPMRedirAcc.so.3
# dpm.replacementprefix /alice /dpm/example.com/home/alice
# dpm.fixedidrestrict /dpm/example.com/home/alice
#
# User must be listed in lcgdm-mapfile
# dpm.principal alicetoken
# dpm.fqan /alice

xrootd.monitor all rbuff 32k auth flush 30s window 5s dest files info user io redir atl-prod05.slac.stanford.edu:9930
xrd.report atl-prod05.slac.stanford.edu:9931 every 60s all -buff -poll sync

# vomsxrd: dpm.nohv1 else dpm.listvoms
#dpm.listvoms
dpm.nohv1
';

use constant FED_REDIRECT_CONF => 'xrootd.redirect grid05.lal.in2p3.fr:11001 /store/
';

use constant FED_REDIRECT_EXPECTED => 'xrootd.redirect grid05.lal.in2p3.fr:11001 /store/
';


#############
# Main code #
#############

$CAF::Object::NoAction = 1;
set_caf_file_close_diff(1);

my $comp = NCM::Component::xrootd->new('xrootd');

my $config = get_config_for_profile("local-redir");
my $xrootd_options = $config->getElement("/software/components/xrootd/options")->getTree();
my $local_redir_rules = $comp->getRules("redir");
my %parser_options;
$parser_options{remove_if_undef} = 1;

# Initial file empty
set_file_contents(REDIR_CONF_FILE,"");
my $changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
my $fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_1, REDIR_CONF_FILE." (minimal) has expected contents");
$fh->close();

# Initial file identical to expected results
set_file_contents(REDIR_CONF_FILE,REDIR_INITIAL_CONF);
$changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
$fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_2, REDIR_CONF_FILE." (initial ok) has expected contents");
$fh->close();

# Federation redirect disabled
set_file_contents(REDIR_CONF_FILE,REDIR_INITIAL_CONF.FED_REDIRECT_CONF);
$changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
$fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_2."#".FED_REDIRECT_EXPECTED, REDIR_CONF_FILE." (fed disabled) has expected contents");
$fh->close();


# Federation redirect: different combinations of initial config
$config = get_config_for_profile("cms-fed-redir");
$xrootd_options = $config->getElement("/software/components/xrootd/options")->getTree();
$local_redir_rules = $comp->getRules("redir");
$comp->mergeLocalRedirects($xrootd_options);

set_file_contents(REDIR_CONF_FILE,REDIR_INITIAL_CONF.FED_REDIRECT_CONF);
$changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
$fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_2.FED_REDIRECT_EXPECTED, REDIR_CONF_FILE." (fed enabled) has expected contents");
$fh->close();

set_file_contents(REDIR_CONF_FILE,REDIR_INITIAL_CONF."#".FED_REDIRECT_CONF);
$changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
$fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_2.FED_REDIRECT_EXPECTED, REDIR_CONF_FILE." (init fed disabled )has expected contents");
$fh->close();

set_file_contents(REDIR_CONF_FILE,REDIR_INITIAL_CONF);
$changes = $comp->updateConfigFile(REDIR_CONF_FILE,
                                      $local_redir_rules,
                                      $xrootd_options,
                                      \%parser_options);
$fh = get_file(REDIR_CONF_FILE);
ok(defined($fh), REDIR_CONF_FILE." was opened");
is("$fh", REDIR_EXPECTED_CONF_2.FED_REDIRECT_EXPECTED, REDIR_CONF_FILE." (init fed absent) has expected contents");
$fh->close();


Test::NoWarnings::had_no_warnings();

