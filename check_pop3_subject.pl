#! /usr/bin/perl -w
# Hacked together by Zach Armstrong
#
# Some code taken from:  http://mipagina.cantv.net/lem/perl/mfetch
# Some more code taken from: http://www.perlmonks.org/?node_id=196853
#  This is the ultra hack mashup to have a nagios check that checks a pop3 account for an email with a specific subject line.
#
#
# 0 = ok
# 1 = warn
# 2 = crit
# 3 = unknown

#configurable options:
my $debug = 1;
my $deleteMatches = 1;
my $deleteNonMatches = 1;

# No changes below, unless you want to change exit codes
use lib "/usr/local/nagios/libexec" ;
use Net::POP3;
use Getopt::Std;
use strict;
use IO::File;
use warnings;
use MIME::Parser;
use HTML::Parser;
use Unicode::Map8;

use utils qw( %ERRORS);

use vars qw(  $wd $e $map $parser);

my $time_start = time;
my $msg_id;
my $subJ;
my %options=();
getopts("H:u:p:s:", \%options);
my $matchCount =0; #do not edit
my $deletedSpamCount =0; #do not edit

if (scalar(keys(%options))<4 ){
        print "usage: $0 -u username -p password -H hostname -s search_string \n";
        print "\n searches the subject for the given search_string, case sensative\n";
        exit  $ERRORS{'UNKNOWN'}; # This will register as unknown in nagios
}

my $i=0;
my $exit_value = $ERRORS{'UNKNOWN'} ;
my $pop;
my $return_val;

while ((!$pop) && (!$return_val) && ($i < 3))
{
$pop = Net::POP3->new($options{'H'}, 'Timeout' => 60, 'Debug' => 0);
unless (($pop) && ($i < 3)) { print "Unable to establish pop3 connection (tried $i times)!\n"; exit $ERRORS{'UNKNOWN'}; }

$return_val = $pop->login($options{'u'}, $options{'p'});
unless (($return_val) && ($i < 3)) {
print "Unable to connect - invalid user/password or a timeout has occured\n"; exit $ERRORS{'CRITICAL'};
}
$i++;
}

my $Messages = $pop->list();
if ($Messages > 0)
{

        for $msg_id (keys(%$Messages))
        {
                if ($debug) { print "Retrieving Msg: $msg_id\n"; }
                my $fh = new_tmpfile IO::File
                        or blowUpB();
                my $MsgContent = $pop->get($msg_id, $fh);
                 $fh->seek(0, SEEK_SET);
                my $mp = new MIME::Parser;
                $mp->output_dir("/tmp");
                $mp->ignore_errors(1);
                $mp->extract_uuencode(1);
                eval { $e = $mp->parse($fh); };
                my $error = ($@ || $mp->last_error);

                if ($error)
                {
                    $mp->filer->purge;          # Get rid of the temp files
                    print "Error parsing the message: $error\n";
                    exit $ERRORS{'UNKNOWN'};
                }

                my $parser = HTML::Parser->new
                    (
                     api_version => 3,
                     default_h          => [ "" ],
                     start_h => [ sub { print "[IMG ",
                                        d($_[1]->{alt}) || $_[1]->{src},"]\n"
                                            if $_[0] eq 'img';
                                    }, "tagname, attr" ],
                     text_h => [ sub { print d(shift); }, "dtext" ],
                     );

                $parser->ignore_elements(qw(script style));
                $parser->strict_comment(1);
                $map = Unicode::Map8->new('ASCII')
                or blowUp();

                setup_decoder($e->head);
                $subJ = d($e->head->get('subject'));
                if ($subJ =~ m/$options{'s'}/)
                {
                         if ($debug) {  print "Found ", $options{'s'}, " in subject\n"; }
                         $matchCount++;
                        $exit_value =$ERRORS{'OK'};
                        if ($deleteMatches)
                        { if ($debug) { print "Deleting message ", $msg_id,"\n"; }  my $delete_msg = $pop->delete($msg_id); }
                }
                else
                {
                        if ($debug) {  print  $options{'s'}, " NOT FOUND in subject\n"; }
                        if ($deleteNonMatches)
                        { if ($debug) { print "Deleting message ", $msg_id,"\n"; }  my $delete_msg = $pop->delete($msg_id); $deletedSpamCount++; }

                }

                #  decode_entities($e);
                if ($debug) {  print "Subject: ", $subJ, "\n"; }

                $mp->filer->purge;
                #  my $delete_msg = $pop3->delete($msg_id) unless ($opt_c);
        }

} else {
        print "Error: was unable to connect to POP account.\r\n";
        $exit_value = $ERRORS{'UNKNOWN'};
}

$pop->quit;

my $time_end = time;
my $elapsedtime = $time_end - $time_start;
my $report;
if ($exit_value == 0)
{
        $report = "POP3 Receive OK: " . $elapsedtime . " seconds elapsed, " . $matchCount . " found";
        if ($deleteMatches)
        {
                $report = $report . ", " . $matchCount . " deleted";
        } else {
                $report = $report . ", deleting DISABLED";
        }
        if ($deleteNonMatches)
        {
                $report = $report . ", " . $deletedSpamCount . " non-matches deleted";
        } else {
                $report = $report . ", deleting non-matches DISABLED";
        }
        print ($report . "\n");
} elsif ($matchCount == 0 ) {
        print "No messages found!";
        $exit_value = 2;
}

exit $exit_value;

sub blowUp { print "Cannot create character map\n"; exit $ERRORS{'CRITICAL'}; }

sub blowUpB { print "Cannot create temporary file: $!\n"; exit $ERRORS{'CRITICAL'}; }

sub d { $map->to8($map->to16($wd->decode(shift||''))); }

sub setup_decoder
{
    my $head = shift;
    if ($head->get('Content-Type')
        and $head->get('Content-Type') =~ m!charset="([^\"]+)"!)
    {
        $wd = supported MIME::WordDecoder uc $1;
    }
    $wd = supported MIME::WordDecoder "ISO-8859-1" unless $wd;
}

sub decode_entities
{
    my $ent = shift;

    if (my @parts = $ent->parts)
    {
        decode_entities($_) for @parts;
    }
    elsif (my $body = $ent->bodyhandle)
    {
        my $type = $ent->head->mime_type;

        setup_decoder($ent->head);

        if ($type eq 'text/plain')
        { print d($body->as_string); }
        elsif ($type eq 'text/html')
        { $parser->parse($body->as_string); }
        else
        { print "[Unhandled part of type $type]"; }
    }
}
                
                
