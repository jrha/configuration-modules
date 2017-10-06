################################################################################
# ex: set expandtab softtabstop=4 shiftwidth=4: -*- cperl-indent-level: 4; indent-tabs-mode: nil -*-
################################################################################
#
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

################################################################################
# Coding style: emulate <TAB> characters with 4 spaces, thanks!
################################################################################
#
# /software/components/nss: generate /etc/nsswitch.conf
# If any db is marked as "db", allow rebuilding of the db?
#
###############################################################################

package NCM::Component::nss;

#
# a few standard statements, mandatory for all components
#

use strict;
use warnings;

use CAF::Process;
use NCM::Component;
use vars qw(@ISA $EC);
@ISA = qw(NCM::Component);
$EC = LC::Exception::Context->new->will_store_all;

our $NoActionSupported = 1;

##########################################################################
sub Configure {
##########################################################################
    my ($self,$config) = @_;

    my $prefix = "/software/components/nss";
    if (!$config->elementExists("$prefix/databases")) {
        return 1;
    }

    my $rebuild = {};
    my $databases = {};
    my $dblist = $config->getElement("$prefix/databases")->getTree;
    foreach my $db (keys %$dblist) {
        $databases->{$db} = join(" ", @{$dblist->{$db}});
        foreach my $d (@{$dblist->{$db}}) {
            next unless $d =~ m{^\w+$};
            # Currently, this sets the rebuild, not appends, so only one rebuild per db is supported.
            if ($config->elementExists("$prefix/build/$d/script")) {
                $rebuild->{$db} = [ $d, $config->getElement("$prefix/build/$d/script")->getValue() ];
            } elsif ($config->elementExists("$prefix/build/ALL/script")) {
                $rebuild->{$db} = [ $d, $config->getElement("$prefix/build/ALL/script")->getValue() ];
            }
        }
    }

    # Now perform any required rebuilds
    my $skipped = 0;
    my @rebuild = keys %$rebuild;
    my $done = {};
    while (@rebuild) {
        if ($skipped == scalar @rebuild) {
            # we're looping without getting anything done. give up.
            $self->error("cannot rebuild databases due to cyclic dependencies");
            return 0;
        }
        my $db = shift @rebuild;
        my ($dbtype, $cmd) = @{$rebuild->{$db}};

        my $depkey = "$prefix/build/$dbtype/depends";
        if ($config->elementExists($depkey)) {
            my $dep = $config->getElement($depkey)->getValue;
            if ($dep ne $db && exists $rebuild->{$dep} && !$done->{$dep}) {
                push(@rebuild, $db);
                $skipped++;
                next;
            }
        }
        $skipped = 0;
        # For non-active DB's, we act as if they were rebuilt, in order
        # to ensure that we still process dependencies.
        my $activekey = "$prefix/build/$dbtype/active";
        if ($config->elementExists($activekey) && $config->getElement($activekey)->getValue eq 'true') {
            if (!$self->buildDB($cmd, $db)) {
                return 0;
            }
        }
        $done->{$db}++;
    }

    my @new = ( "# Generated by ncm-nss\n\n" );
    push(@new, map { "$_: $databases->{$_}\n" } sort keys %$databases);
    my $fh = CAF::FileWriter->open("/etc/nsswitch.conf",
                                   backup => ".OLD",
                                   owner => "root",
                                   group => "root",
                                   mode => 0444,
                                   log => $self,
        );
    print $fh join("", @new);
    my $result = $fh->close();

    if ($result) {
        $self->info("updated /etc/nsswitch.conf") unless $NoAction;

        # if nscd is running, then restart it.
        if ($^O eq 'linux') {
            my $nscdrestart = CAF::Process->new(
                ['service', 'nscd', 'condrestart'], log => $self);
            $nscdrestart->execute();
            # wait for nscd to restart before returning in case
            # another component in the same ncm-ncd run depends on
            # any changed config
            sleep 2;
        } else {
            $self->warn("Unrecognised platform, $^O, not restarting nscd");
        }
    }
    return 1;
}

sub buildDB {
    my ($self, $script, $name) = @_;
    $script =~ s{<DB>}{$name}g;
    my $proc = CAF::Process->new([split(/ +/, $script)], log => $self);
    my $out = $proc->output();
    if ($?) {
        $self->error("running '$script' failed: $out");
        return 0;
    } else {
        # the command itself is already logged as VERBOSE
        $self->debug(1, $out);
    }
    return 1;
}

1; #required for Perl modules
