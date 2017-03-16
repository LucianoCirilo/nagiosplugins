#!/usr/bin/perl

# author: Patrick Zambelli <patrick.zambelli@wuerth-phoenix.com>
# adapted for HP BladeSystem from check_snmp_IBM_Bladecenter.pl 
# author Eric Schultz <eric.schultz@mentaljynx.com>
# what:    monitor various aspects of the HP Bladesystem
# license: GPL - http://www.fsf.org/licenses/gpl.txt
#
# =========================================================================== #
# Usage: $PROGNAME -H <host> -C <snmp_community> -t <test_name> [-n <ele-num>] [-w <low>,<high>] [-c <low>,<high>] [-o <timeout>] \n"; }
#/usr/lib/nagios/plugins/check_snmp_HP_Bladesystem.pl -H 10.62.5.161 -C public -w 3: -c 4: -t Fan-Conditions
# OK Fan-Conditions (2) Fan return codes: 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 
# The overall return condition is 2 = OK. Array of integers holds the return status of the single fans.
#

use strict;
require 5.6.0;
use lib qw( /opt/nagios/libexec );
use utils qw(%ERRORS $TIMEOUT &print_revision &support &usage);
use Net::SNMP;
use Getopt::Long;
use vars qw/$exit $message $opt_version $opt_timeout $opt_help $opt_command $opt_host $opt_community $opt_verbose 
$opt_warning $opt_critical $opt_port $opt_mountpoint $snmp_session $PROGNAME $TIMEOUT $test_details $test_name $test_num/;

$PROGNAME      = "check_snmp_HP_Bladesystem.pl";
$opt_verbose   = undef;
$opt_host      = undef;
$opt_community = 'public';
$opt_command   = undef;
$opt_warning   = undef;
$opt_critical  = undef;
$opt_port      = 161;
$message       = undef;
$exit          = 'OK';
$test_details  = undef;
$test_name     = undef;
$test_num      = 1;


# =========================================================================== #
# =====> MAIN
# =========================================================================== #
process_options();

alarm( $TIMEOUT ); # make sure we don't hang Nagios

my $snmp_error;
($snmp_session,$snmp_error) = Net::SNMP->session(
		-version => 'snmpv2c',
		-hostname => $opt_host,
		-community => $opt_community,
		-port => $opt_port,
		);
my $oid;
my $oid_prefix = ".1.3.6.1.4.1."; #Enterprises
$oid_prefix .= "232.22.2."; #HP Bladesystem

$|=1;

my ($data,$data_text)=('','');

if($test_name =~ m/^System-State$/i){
	$oid = "3.1.1.1.16.1";
	$data = SNMP_getvalue($snmp_session,$oid_prefix.$oid);
	$data_text='UnKnown';
	$data_text='Normal system state.' if $data eq 2;
	$data_text='Sytem degraded' if $data eq 3;
	$data_text='Undefined System Error' if $data eq 1;
	$data_text='Critical System failure' if $data eq 4;
	}
elsif($test_name =~ m/^Fan-Conditions$/i){
	#Check iterates all fan OIDs: error if one fan is on warning or critical
    $oid = "3.1.3.1.11.";
    my $data_fan;
    $data_text="Fan return codes: ";
    $data = 0;
    for (my $i = 1;$i<=15;$i++){
        $data_fan = SNMP_getvalue($snmp_session,$oid_prefix.$oid.$i);
        if (int($data_fan)){
            $data_text .=$data_fan."; ";
        
            #hold the highest return or a return diff from 2. i.e.1
            if (($data_fan > $data) or ($data_fan != 2)){
                $data = $data_fan;
            }
        }
    }
  #$data = SNMP_getvalue($snmp_session,$oid_prefix.$oid);
	#$data_text=$data;
	}
elsif($test_name =~ m/^Power-Supply$/i){
	#Check iterates all Power Supply OIDs: error if one fan is on warning or critical
    $oid = "5.1.1.1.17.";
    my $data_ps;
    $data_text="Power Supply return codes: ";
    $data = 0;
    for (my $i = 1;$i<=9;$i++){
        $data_ps = SNMP_getvalue($snmp_session,$oid_prefix.$oid.$i);
        if (int($data_ps)){
            $data_text .=$data_ps."; ";
            
            #hold the highest return or a return diff from 2. i.e.1
            if (($data_ps > $data) or ($data_ps != 2)){
                $data = $data_ps;
            }
        }
    }
	}

$snmp_session->close;
alarm( 0 ); # we're not going to hang after this.

# Parse our the thresholds. and set the result
my ($ow_low,$ow_high,$oc_low,$oc_high) = parse_thres($opt_warning,$opt_critical);

my $res = "OK";
#changed to match critial with passed value
$res = "WARNING" if( $ow_low ne '' and $data == $ow_low );
$res = "CRITICAL" if( $oc_low ne '' and $data == $oc_low );

#print "$ow_low:$ow_high $oc_low:$oc_high\n";
print "$res $test_name ($data) $data_text\n";
exit $ERRORS{$res};

# =========================================================================== #
# =====> Sub-Routines
# =========================================================================== #

sub parse_thres{
	my ($opt_warning,$opt_critical)=@_;
	my ($ow_low,$ow_high) = ('','');
	if($opt_warning){
		if($opt_warning =~ m/^(\d*?):(\d*?)$/){ ($ow_low,$ow_high) = ($1,$2); }
		elsif($opt_warning =~ m/^\d+$/){ ($ow_low,$ow_high)=(-1,$opt_warning); }
		}
	my ($oc_low,$oc_high) = ('','');
	if($opt_critical){
		if($opt_critical =~ m/^(\d*?):(\d*?)$/){ ($oc_low,$oc_high) = ($1,$2); }
		elsif($opt_critical =~ m/^\d+$/){ ($oc_low,$oc_high)=(-1,$opt_critical); }
		}
	return($ow_low,$ow_high,$oc_low,$oc_high);
	}

sub process_options {
	Getopt::Long::Configure( 'bundling' );
	GetOptions(
			'V'     => \$opt_version,       'version'     => \$opt_version,
			'v'     => \$opt_verbose,       'verbose'     => \$opt_verbose,
			'h'     => \$opt_help,          'help'        => \$opt_help,
			'H:s'   => \$opt_host,          'hostname:s'  => \$opt_host,
			'p:i'   => \$opt_port,          'port:i'      => \$opt_port,
			'C:s'   => \$opt_community,     'community:s' => \$opt_community,
			'c:s'   => \$opt_critical,          'critical:s'  => \$opt_critical,
			'w:s'   => \$opt_warning,          'warning:s'   => \$opt_warning,
			'o:i'   => \$TIMEOUT,           'timeout:i'   => \$TIMEOUT,
			'T:s'	=> \$test_details,	'test-help:s' => \$test_details,
			't:s'	=> \$test_name,		'test:s'      => \$test_name,
			'n:i'	=> \$test_num,		'ele-number:i'      => \$test_num
		  );
	if ( defined($opt_version) ) { local_print_revision(); }
	if ( defined($opt_verbose) ) { $SNMP::debugging = 1; }
	if ( !defined($opt_host) || defined($opt_help) 
		|| defined($test_details) || !defined($test_name) ) {
		
		print_help();
		if(defined($test_details)) { print_test_details($test_details); }
		exit $ERRORS{UNKNOWN};
		}
	}

sub print_test_details{
	my ($t_name) = @_;
	print "\n\nDETAILS FOR: $t_name\n";
	my %test_help;
	$test_help{'System-State'}=<<__END;
Returns the System State Code, Values are:
	2	ok
	3	warning
	4	critical
	1	Unknown
__END
	
	$test_help{'Fan-Conditions'}=<<__END;;
Returns the System Fan condition: A check over all system fans is done and the overall return is the worst single return value. i.e. 2 = ok, if and only if all fans return 2 the final fan-status return will be 2.
__END
	$test_help{'Power-Supply'}=<<__END;;
Returns the System Power Supply condition: A check over all system power supplies is done and the overall return is the worst single return value. i.e. 2 = ok, if and only if all power supplies return 2 the final power-supply-status return will be 2.
__END

	print $test_help{$t_name};
}

sub local_print_revision { print_revision( $PROGNAME, '$Revision: 1.0 $ ' ); }

sub print_usage { print "Usage: $PROGNAME -H <host> -C <snmp_community> -t <test_name> [-n <ele-num>] [-w <low>,<high>] [-c <low>,<high>] [-o <timeout>] \n"; }

sub SNMP_getvalue{
	my ($snmp_session,$oid) = @_;

	my $res = $snmp_session->get_request(
			-varbindlist => [$oid]);
	
	if(!defined($res)){
		print "ERROR: ".$snmp_session->error."\n";
		exit;
		}
	
	return($res->{$oid});
	}

sub print_help {
	local_print_revision();
	print "Copyright (c) 2008 Patrick Zambelli <patrick.zambelli\@wuerth-phoenix.com> based on code of  Eric Schultz <eric.schultz\@mentaljynx.com>\n\n",
	      "SNMP HP Bladesystem plugin for Nagios\n\n";
	print_usage();
print <<EOT;
	-v, --verbose
		print extra debugging information
	-h, --help
		print this help message
	-H, --hostname=HOST
		name or IP address of host to check
	-C, --community=COMMUNITY NAME
		community name for the host's SNMP agent
	-w, --warning=INTEGER
		percent of disk used to generate WARNING state (Default: 99)
	-c, --critical=INTEGER
		percent of disk used to generate CRITICAL state (Default: 100)
	-T, --test-help=TEST NAME
		print Test Specific help for A Specific Test
	-t, --test=TEST NAME
		test to run
	-n, --ele-number=ELEMEMNT NUM
		Number of blade/blower/power module

POSSIBLE TESTS:
	System-State
	Fan-Conditions
    Power-Supply
EOT

	}

sub verbose (@) {
	return if ( !defined($opt_verbose) );
	print @_;
	}

