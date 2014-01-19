=head1 NAME

Weather Stats to your Moorescloud Holiday lights

=head1 SYNOPSIS

This is a perl script. Save it onto a computer on your local network where the Holiday lights also live.  At the command line type the following:

perl bom.pl

or open the script from a GUI 
or make it an executable 
or something. 

Oh, but before that, you do need to customise some of the things inside this script to make it work in your environment. There are obvious things at the head of the code proper to change to make this work in your environment, but I will describe it here as well to give some guidance.

Your Holiday lights have their own IP address on your network. You will need to put that into the code.  This is something you will know from having set up the lights in your environment.

You will be interested in a particular location for weather. You will need to put that into the code. Specifically, you will need to have the URL for the JSON feed for that location.

=head1 DESCRIPTION

This script retrieves Bureau of Meterology weather updates for a location in Australia and displays it to your Moorescloud Holiday Lights.

=head2 SETTING UP YOUR MOORESCLOUD LIGHTS

The Moorescloud lights are a string of 50 light bulbs that can display any colour you will need.  Now, being a string of lights, one is obliged to contort them into a grid pattern for the purposes of displaying messages or weather update information.

Oh, and one actually needs to have a set of Moorescloud Holiday lights. I have used masking tape and a wall to achieve the effect. Perhaps I ought to design a mounting board and sell it on the internet...

Specifically, the lights need to be laid out in a grid, as follows:

        O-O-O-O-O-O-O-O-O-O
                          |
        O-O-O-O-O-O-O-O-O-O
        |
        O-O-O-O-O-O-O-O-O-O
                          |
        O-O-O-O-O-O-O-O-O-O
        |
        O-O-O-O-O-O-O-O-O-O----------[O]------------E

The -O- represent the lights on the string, the [O] represents the control box and the ---E represents the power plug that goes into the wall. The control box is actually a linux computer, but you can read about all that on the moorescloud site.

The five rows of ten columns is the display grid for the scrolling text that will be the weather updates within this script. At first, I used this grid layout to display messages that I put into a string variable, which I have in another bunch of scripts that I haven't uploaded to github, but I figure you get the idea. 

=head1 BUGS and CAVEATS

I am not a proper programmer, so I'm sure you'll discover things. Many things. 

I am also not a font designer, so you may well decide to improve attempt at representing letters, numbers and symbols. I look forward to using your improvements.

=head1 NEXT STEPS

Clearly this can be extended to a grid of greater dimensions by connecting up a bunch of Holiday strings. 

Lose weight. Learn python.

=head1 ACKNOWLEDGEMENTS

Well, I need to acknowledge Moorescloud http://www.moorescloud.com/ for the Holiday lights, being the little blighters this perl program is talking to.

One needs to acknowledge the Bureau Of Meteorology, Australia, who provide data feeds to the weather in this fine country. http://www.bom.gov.au/catalogue/data-feeds.shtml

=head1 COPYRIGHT

Do as you like with this, but feel mildly obliged to mention that you happened across this perl script from @sylmobile, who in turned borrowed from everyone on the internet at some point.

=head1 AVAILABILITY

Visit github, I suppose...

=head1 AUTHOR

Sylvano. I can be contacted via twitter at @sylmobile or via email at sylmobile@sylmobile.com

=head1 SEE ALSO

This section is too demanding. Use google.

=head1 Technical Points

This script uses the UDP based (SecretAPI) access to the Holiday lights. That means it uses sockets and JSON to talk to the lights. The scrript also uses JSON and curl to talk with the Bureau Of Meteorology (BOM). This explains the modules it uses. You may need to install perl modules to make this work.

 

=cut


use strict;
use warnings;

# We need all the modules
use IO::Socket;
use List::Util qw[min max];
use Time::HiRes qw( usleep );
use JSON;
use LWP::Curl;

my $debug = 'no'; # 'yes' or 'no';

# We need urls for the BOM info
#
# I've got this pointed at the Sydney Ob
my $referer = 'http://www.bom.gov.au/';
my $get_url = 'http://www.bom.gov.au/fwo/IDN60901/IDN60901.94768.json';
my %bom
  ;   # variable to store the information we want to use from the bom JSON feed.

# Define the time delay
my $scroll_delay = 200000;    #micro (millionths) seconds

$scroll_delay = max( 80000, $scroll_delay )
  ;    # enforce 10Hz maximum rate, because @mpesce said so

# Define the colour pallette

my %colours;

$colours{'.'} = '000000';    # light OFF colour
$colours{'R'} = 'ff0000';    # full red
$colours{'r'} = 'ff0000';    # light red

#========================================
# SETUP PARAMETERS FOR THE LIGHTS
#========================================

#define the light address and port
my $stringaddress = '10.0.0.29';
my $stringport    = 9988;

# create our socket object

my $sock = IO::Socket::INET->new(
    Proto    => 'udp',
    PeerPort => $stringport,
    PeerAddr => $stringaddress,
) or die "Could not create socket: $!\n";

#========================================
# Define letter structures
#========================================

my %chr;

# letter A
$chr{A}[0][0] = 4;    # width
$chr{A}[0][1] = 5;    # height
( $chr{A}[1][1], $chr{A}[1][2], $chr{A}[1][3], $chr{A}[1][4] ) =  split( '', '.RR.' );
( $chr{A}[2][1], $chr{A}[2][2], $chr{A}[2][3], $chr{A}[2][4] ) =  split( '', 'R..R' );
( $chr{A}[3][1], $chr{A}[3][2], $chr{A}[3][3], $chr{A}[3][4] ) =  split( '', 'RRRR' );
( $chr{A}[4][1], $chr{A}[4][2], $chr{A}[4][3], $chr{A}[4][4] ) =  split( '', 'R..R' );
( $chr{A}[5][1], $chr{A}[5][2], $chr{A}[5][3], $chr{A}[5][4] ) =  split( '', 'R..R' );

$chr{a}[0][0] = 4;    # width
$chr{a}[0][1] = 5;    # height
( $chr{a}[1][1], $chr{a}[1][2], $chr{a}[1][3], $chr{a}[1][4] ) =  split( '', '.RR.' );
( $chr{a}[2][1], $chr{a}[2][2], $chr{a}[2][3], $chr{a}[2][4] ) =  split( '', '...R' );
( $chr{a}[3][1], $chr{a}[3][2], $chr{a}[3][3], $chr{a}[3][4] ) =  split( '', '.RRR' );
( $chr{a}[4][1], $chr{a}[4][2], $chr{a}[4][3], $chr{a}[4][4] ) =  split( '', 'R..R' );
( $chr{a}[5][1], $chr{a}[5][2], $chr{a}[5][3], $chr{a}[5][4] ) =  split( '', '.RRr' );

# letter B
$chr{B}[0][0] = 4;    # width
$chr{B}[0][1] = 5;    # height
( $chr{B}[1][1], $chr{B}[1][2], $chr{B}[1][3], $chr{B}[1][4] ) =  split( '', 'RRR.' );
( $chr{B}[2][1], $chr{B}[2][2], $chr{B}[2][3], $chr{B}[2][4] ) =  split( '', 'R..r' );
( $chr{B}[3][1], $chr{B}[3][2], $chr{B}[3][3], $chr{B}[3][4] ) =  split( '', 'RRR.' );
( $chr{B}[4][1], $chr{B}[4][2], $chr{B}[4][3], $chr{B}[4][4] ) =  split( '', 'R..r' );
( $chr{B}[5][1], $chr{B}[5][2], $chr{B}[5][3], $chr{B}[5][4] ) =  split( '', 'RRR.' );

$chr{b}[0][0] = 4;    # width
$chr{b}[0][1] = 5;    # height
( $chr{b}[1][1], $chr{b}[1][2], $chr{b}[1][3], $chr{b}[1][4] ) =  split( '', 'R...' );
( $chr{b}[2][1], $chr{b}[2][2], $chr{b}[2][3], $chr{b}[2][4] ) =  split( '', 'R...' );
( $chr{b}[3][1], $chr{b}[3][2], $chr{b}[3][3], $chr{b}[3][4] ) =  split( '', 'RRR.' );
( $chr{b}[4][1], $chr{b}[4][2], $chr{b}[4][3], $chr{b}[4][4] ) =  split( '', 'R..r' );
( $chr{b}[5][1], $chr{b}[5][2], $chr{b}[5][3], $chr{b}[5][4] ) =  split( '', 'RRR.' );

# letter C
$chr{C}[0][0] = 4;    # width
$chr{C}[0][1] = 5;    # height
( $chr{C}[1][1], $chr{C}[1][2], $chr{C}[1][3], $chr{C}[1][4] ) = split( '', '.RRr' );
( $chr{C}[2][1], $chr{C}[2][2], $chr{C}[2][3], $chr{C}[2][4] ) = split( '', 'R...' );
( $chr{C}[3][1], $chr{C}[3][2], $chr{C}[3][3], $chr{C}[3][4] ) = split( '', 'R...' );
( $chr{C}[4][1], $chr{C}[4][2], $chr{C}[4][3], $chr{C}[4][4] ) = split( '', 'R...' );
( $chr{C}[5][1], $chr{C}[5][2], $chr{C}[5][3], $chr{C}[5][4] ) = split( '', '.RRr' );

$chr{c}[0][0] = 4;    # width
$chr{c}[0][1] = 5;    # height
( $chr{c}[1][1], $chr{c}[1][2], $chr{c}[1][3], $chr{c}[1][4] ) = split( '', '....' );
( $chr{c}[2][1], $chr{c}[2][2], $chr{c}[2][3], $chr{c}[2][4] ) = split( '', '....' );
( $chr{c}[3][1], $chr{c}[3][2], $chr{c}[3][3], $chr{c}[3][4] ) = split( '', '.RR.' );
( $chr{c}[4][1], $chr{c}[4][2], $chr{c}[4][3], $chr{c}[4][4] ) = split( '', 'R...' );
( $chr{c}[5][1], $chr{c}[5][2], $chr{c}[5][3], $chr{c}[5][4] ) = split( '', '.RR.' );

# letter D
$chr{D}[0][0] = 4;    # width
$chr{D}[0][1] = 5;    # height
( $chr{D}[1][1], $chr{D}[1][2], $chr{D}[1][3], $chr{D}[1][4] ) = split( '', 'RRR.' );
( $chr{D}[2][1], $chr{D}[2][2], $chr{D}[2][3], $chr{D}[2][4] ) = split( '', 'R..R' );
( $chr{D}[3][1], $chr{D}[3][2], $chr{D}[3][3], $chr{D}[3][4] ) = split( '', 'R..R' );
( $chr{D}[4][1], $chr{D}[4][2], $chr{D}[4][3], $chr{D}[4][4] ) = split( '', 'R..R' );
( $chr{D}[5][1], $chr{D}[5][2], $chr{D}[5][3], $chr{D}[5][4] ) = split( '', 'RRR.' );

$chr{d}[0][0] = 4;    # width
$chr{d}[0][1] = 5;    # height
( $chr{d}[1][1], $chr{d}[1][2], $chr{d}[1][3], $chr{d}[1][4] ) =  split( '', '...R' );
( $chr{d}[2][1], $chr{d}[2][2], $chr{d}[2][3], $chr{d}[2][4] ) =  split( '', '...R' );
( $chr{d}[3][1], $chr{d}[3][2], $chr{d}[3][3], $chr{d}[3][4] ) =  split( '', '.RRR' );
( $chr{d}[4][1], $chr{d}[4][2], $chr{d}[4][3], $chr{d}[4][4] ) =  split( '', 'R..R' );
( $chr{d}[5][1], $chr{d}[5][2], $chr{d}[5][3], $chr{d}[5][4] ) =  split( '', '.RRr' );

# letter E
$chr{E}[0][0] = 4;    # width
$chr{E}[0][1] = 5;    # height
( $chr{E}[1][1], $chr{E}[1][2], $chr{E}[1][3], $chr{E}[1][4] ) =  split( '', 'RRRR' );
( $chr{E}[2][1], $chr{E}[2][2], $chr{E}[2][3], $chr{E}[2][4] ) =  split( '', 'R...' );
( $chr{E}[3][1], $chr{E}[3][2], $chr{E}[3][3], $chr{E}[3][4] ) =  split( '', 'RRR.' );
( $chr{E}[4][1], $chr{E}[4][2], $chr{E}[4][3], $chr{E}[4][4] ) =  split( '', 'R...' );
( $chr{E}[5][1], $chr{E}[5][2], $chr{E}[5][3], $chr{E}[5][4] ) =  split( '', 'RRRR' );

$chr{e}[0][0] = 4;    # width
$chr{e}[0][1] = 5;    # height
( $chr{e}[1][1], $chr{e}[1][2], $chr{e}[1][3], $chr{e}[1][4] ) =  split( '', '.RR.' );
( $chr{e}[2][1], $chr{e}[2][2], $chr{e}[2][3], $chr{e}[2][4] ) =  split( '', 'R..R' );
( $chr{e}[3][1], $chr{e}[3][2], $chr{e}[3][3], $chr{e}[3][4] ) =  split( '', 'RRR.' );
( $chr{e}[4][1], $chr{e}[4][2], $chr{e}[4][3], $chr{e}[4][4] ) =  split( '', 'R...' );
( $chr{e}[5][1], $chr{e}[5][2], $chr{e}[5][3], $chr{e}[5][4] ) =  split( '', '.RRR' );

# letter F
# letter F
$chr{F}[0][0] = 4;    # width
$chr{F}[0][1] = 5;    # height
( $chr{F}[1][1], $chr{F}[1][2], $chr{F}[1][3], $chr{F}[1][4] ) =  split( '', 'RRRR' );
( $chr{F}[2][1], $chr{F}[2][2], $chr{F}[2][3], $chr{F}[2][4] ) =  split( '', 'R...' );
( $chr{F}[3][1], $chr{F}[3][2], $chr{F}[3][3], $chr{F}[3][4] ) =  split( '', 'RRR.' );
( $chr{F}[4][1], $chr{F}[4][2], $chr{F}[4][3], $chr{F}[4][4] ) =  split( '', 'R...' );
( $chr{F}[5][1], $chr{F}[5][2], $chr{F}[5][3], $chr{F}[5][4] ) =  split( '', 'R...' );

$chr{f}[0][0] = 4;    # width
$chr{f}[0][1] = 5;    # height
( $chr{f}[1][1], $chr{f}[1][2], $chr{f}[1][3], $chr{f}[1][4] ) =  split( '', '.rRR' );
( $chr{f}[2][1], $chr{f}[2][2], $chr{f}[2][3], $chr{f}[2][4] ) =  split( '', '.R..' );
( $chr{f}[3][1], $chr{f}[3][2], $chr{f}[3][3], $chr{f}[3][4] ) =  split( '', 'RRR.' );
( $chr{f}[4][1], $chr{f}[4][2], $chr{f}[4][3], $chr{f}[4][4] ) =  split( '', '.R..' );
( $chr{f}[5][1], $chr{f}[5][2], $chr{f}[5][3], $chr{f}[5][4] ) =  split( '', '.R..' );

# letter G
# letter G
$chr{G}[0][0] = 4;    # width
$chr{G}[0][1] = 5;    # height
( $chr{G}[1][1], $chr{G}[1][2], $chr{G}[1][3], $chr{G}[1][4] ) =  split( '', '.RRR' );
( $chr{G}[2][1], $chr{G}[2][2], $chr{G}[2][3], $chr{G}[2][4] ) =  split( '', 'R...' );
( $chr{G}[3][1], $chr{G}[3][2], $chr{G}[3][3], $chr{G}[3][4] ) =  split( '', 'R.rR' );
( $chr{G}[4][1], $chr{G}[4][2], $chr{G}[4][3], $chr{G}[4][4] ) =  split( '', 'R..R' );
( $chr{G}[5][1], $chr{G}[5][2], $chr{G}[5][3], $chr{G}[5][4] ) =  split( '', '.RR.' );

$chr{g}[0][0] = 4;    # width
$chr{g}[0][1] = 5;    # height
( $chr{g}[1][1], $chr{g}[1][2], $chr{g}[1][3], $chr{g}[1][4] ) =  split( '', '.RRr' );
( $chr{g}[2][1], $chr{g}[2][2], $chr{g}[2][3], $chr{g}[2][4] ) =  split( '', 'R..R' );
( $chr{g}[3][1], $chr{g}[3][2], $chr{g}[3][3], $chr{g}[3][4] ) =  split( '', '.RRR' );
( $chr{g}[4][1], $chr{g}[4][2], $chr{g}[4][3], $chr{g}[4][4] ) =  split( '', '...R' );
( $chr{g}[5][1], $chr{g}[5][2], $chr{g}[5][3], $chr{g}[5][4] ) =  split( '', '.RR.' );

# letter H
# letter H
$chr{H}[0][0] = 4;    # width
$chr{H}[0][1] = 5;    # height
( $chr{H}[1][1], $chr{H}[1][2], $chr{H}[1][3], $chr{H}[1][4] ) =  split( '', 'R..R' );
( $chr{H}[2][1], $chr{H}[2][2], $chr{H}[2][3], $chr{H}[2][4] ) =  split( '', 'R..R' );
( $chr{H}[3][1], $chr{H}[3][2], $chr{H}[3][3], $chr{H}[3][4] ) =  split( '', 'RRRR' );
( $chr{H}[4][1], $chr{H}[4][2], $chr{H}[4][3], $chr{H}[4][4] ) =  split( '', 'R..R' );
( $chr{H}[5][1], $chr{H}[5][2], $chr{H}[5][3], $chr{H}[5][4] ) =  split( '', 'R..R' );

$chr{h}[0][0] = 4;    # width
$chr{h}[0][1] = 5;    # height
( $chr{h}[1][1], $chr{h}[1][2], $chr{h}[1][3], $chr{h}[1][4] ) =  split( '', 'R...' );
( $chr{h}[2][1], $chr{h}[2][2], $chr{h}[2][3], $chr{h}[2][4] ) =  split( '', 'R...' );
( $chr{h}[3][1], $chr{h}[3][2], $chr{h}[3][3], $chr{h}[3][4] ) =  split( '', 'RRr.' );
( $chr{h}[4][1], $chr{h}[4][2], $chr{h}[4][3], $chr{h}[4][4] ) =  split( '', 'R..r' );
( $chr{h}[5][1], $chr{h}[5][2], $chr{h}[5][3], $chr{h}[5][4] ) =  split( '', 'R..R' );

# letter I
# letter I
$chr{I}[0][0] = 3;    # width
$chr{I}[0][1] = 5;    # height
( $chr{I}[1][1], $chr{I}[1][2], $chr{I}[1][3] ) =  split( '', 'RRR' );
( $chr{I}[2][1], $chr{I}[2][2], $chr{I}[2][3] ) =  split( '', '.R.' );
( $chr{I}[3][1], $chr{I}[3][2], $chr{I}[3][3] ) =  split( '', '.R.' );
( $chr{I}[4][1], $chr{I}[4][2], $chr{I}[4][3] ) =  split( '', '.R.' );
( $chr{I}[5][1], $chr{I}[5][2], $chr{I}[5][3] ) =  split( '', 'RRR' );

$chr{i}[0][0] = 3;    # width
$chr{i}[0][1] = 5;    # height
( $chr{i}[1][1], $chr{i}[1][2], $chr{i}[1][3] ) =  split( '', '.R.' );
( $chr{i}[2][1], $chr{i}[2][2], $chr{i}[2][3] ) =  split( '', '...' );
( $chr{i}[3][1], $chr{i}[3][2], $chr{i}[3][3] ) =  split( '', 'rR.' );
( $chr{i}[4][1], $chr{i}[4][2], $chr{i}[4][3] ) =  split( '', '.R.' );
( $chr{i}[5][1], $chr{i}[5][2], $chr{i}[5][3] ) =  split( '', '.rR' );

# letter J
# letter J
$chr{J}[0][0] = 4;    # width
$chr{J}[0][1] = 5;    # height
( $chr{J}[1][1], $chr{J}[1][2], $chr{J}[1][3], $chr{J}[1][4] ) =  split( '', '.RRR' );
( $chr{J}[2][1], $chr{J}[2][2], $chr{J}[2][3], $chr{J}[2][4] ) =  split( '', '..R.' );
( $chr{J}[3][1], $chr{J}[3][2], $chr{J}[3][3], $chr{J}[3][4] ) =  split( '', '..R.' );
( $chr{J}[4][1], $chr{J}[4][2], $chr{J}[4][3], $chr{J}[4][4] ) =  split( '', 'R.R.' );
( $chr{J}[5][1], $chr{J}[5][2], $chr{J}[5][3], $chr{J}[5][4] ) =  split( '', '.R..' );

$chr{j}[0][0] = 4;    # width
$chr{j}[0][1] = 5;    # height
( $chr{j}[1][1], $chr{j}[1][2], $chr{j}[1][3], $chr{j}[1][4] ) =  split( '', '..R.' );
( $chr{j}[2][1], $chr{j}[2][2], $chr{j}[2][3], $chr{j}[2][4] ) =  split( '', '....' );
( $chr{j}[3][1], $chr{j}[3][2], $chr{j}[3][3], $chr{j}[3][4] ) =  split( '', '.rR.' );
( $chr{j}[4][1], $chr{j}[4][2], $chr{j}[4][3], $chr{j}[4][4] ) =  split( '', '..R.' );
( $chr{j}[5][1], $chr{j}[5][2], $chr{j}[5][3], $chr{j}[5][4] ) =  split( '', 'rR..' );

# letter K
# letter K
$chr{K}[0][0] = 4;    # width
$chr{K}[0][1] = 5;    # height
( $chr{K}[1][1], $chr{K}[1][2], $chr{K}[1][3], $chr{K}[1][4] ) =  split( '', 'R..R' );
( $chr{K}[2][1], $chr{K}[2][2], $chr{K}[2][3], $chr{K}[2][4] ) =  split( '', 'R.R.' );
( $chr{K}[3][1], $chr{K}[3][2], $chr{K}[3][3], $chr{K}[3][4] ) =  split( '', 'RR..' );
( $chr{K}[4][1], $chr{K}[4][2], $chr{K}[4][3], $chr{K}[4][4] ) =  split( '', 'R.R.' );
( $chr{K}[5][1], $chr{K}[5][2], $chr{K}[5][3], $chr{K}[5][4] ) =  split( '', 'R..R' );

$chr{k}[0][0] = 4;    # width
$chr{k}[0][1] = 5;    # height
( $chr{k}[1][1], $chr{k}[1][2], $chr{k}[1][3], $chr{k}[1][4] ) =  split( '', 'R...' );
( $chr{k}[2][1], $chr{k}[2][2], $chr{k}[2][3], $chr{k}[2][4] ) =  split( '', 'R..r' );
( $chr{k}[3][1], $chr{k}[3][2], $chr{k}[3][3], $chr{k}[3][4] ) =  split( '', 'R.R.' );
( $chr{k}[4][1], $chr{k}[4][2], $chr{k}[4][3], $chr{k}[4][4] ) =  split( '', 'RrR.' );
( $chr{k}[5][1], $chr{k}[5][2], $chr{k}[5][3], $chr{k}[5][4] ) =  split( '', 'R..R' );

# letter L
# letter L
$chr{L}[0][0] = 4;    # width
$chr{L}[0][1] = 5;    # height
( $chr{L}[1][1], $chr{L}[1][2], $chr{L}[1][3], $chr{L}[1][4] ) =  split( '', 'R...' );
( $chr{L}[2][1], $chr{L}[2][2], $chr{L}[2][3], $chr{L}[2][4] ) =  split( '', 'R...' );
( $chr{L}[3][1], $chr{L}[3][2], $chr{L}[3][3], $chr{L}[3][4] ) =  split( '', 'R...' );
( $chr{L}[4][1], $chr{L}[4][2], $chr{L}[4][3], $chr{L}[4][4] ) =  split( '', 'R...' );
( $chr{L}[5][1], $chr{L}[5][2], $chr{L}[5][3], $chr{L}[5][4] ) =  split( '', 'RRRR' );

$chr{l}[0][0] = 4;    # width:
$chr{l}[0][1] = 5;    # height
( $chr{l}[1][1], $chr{l}[1][2], $chr{l}[1][3], $chr{l}[1][4] ) =  split( '', 'r...' );
( $chr{l}[2][1], $chr{l}[2][2], $chr{l}[2][3], $chr{l}[2][4] ) =  split( '', '.R..' );
( $chr{l}[3][1], $chr{l}[3][2], $chr{l}[3][3], $chr{l}[3][4] ) =  split( '', '.R..' );
( $chr{l}[4][1], $chr{l}[4][2], $chr{l}[4][3], $chr{l}[4][4] ) =  split( '', '.R..' );
( $chr{l}[5][1], $chr{l}[5][2], $chr{l}[5][3], $chr{l}[5][4] ) =  split( '', '.rR.' );

# letter M
# letter M
$chr{M}[0][0] = 5;    # width
$chr{M}[0][1] = 5;    # height
(
    $chr{M}[1][1], $chr{M}[1][2], $chr{M}[1][3],
    $chr{M}[1][4], $chr{M}[1][5]
) = split( '', 'Rr.rR' );
(
    $chr{M}[2][1], $chr{M}[2][2], $chr{M}[2][3],
    $chr{M}[2][4], $chr{M}[2][5]
) = split( '', 'R.R.R' );
(
    $chr{M}[3][1], $chr{M}[3][2], $chr{M}[3][3],
    $chr{M}[3][4], $chr{M}[3][5]
) = split( '', 'R.R.R' );
(
    $chr{M}[4][1], $chr{M}[4][2], $chr{M}[4][3],
    $chr{M}[4][4], $chr{M}[4][5]
) = split( '', 'R...R' );
(
    $chr{M}[5][1], $chr{M}[5][2], $chr{M}[5][3],
    $chr{M}[5][4], $chr{M}[5][5]
) = split( '', 'R...R' );

$chr{m}[0][0] = 5;    # width
$chr{m}[0][1] = 5;    # height
(
    $chr{m}[1][1], $chr{m}[1][2], $chr{m}[1][3],
    $chr{m}[1][4], $chr{m}[1][5]
) = split( '', '.....' );
(
    $chr{m}[2][1], $chr{m}[2][2], $chr{m}[2][3],
    $chr{m}[2][4], $chr{m}[2][5]
) = split( '', '.R.R.' );
(
    $chr{m}[3][1], $chr{m}[3][2], $chr{m}[3][3],
    $chr{m}[3][4], $chr{m}[3][5]
) = split( '', 'R.R.R' );
(
    $chr{m}[4][1], $chr{m}[4][2], $chr{m}[4][3],
    $chr{m}[4][4], $chr{m}[4][5]
) = split( '', 'R...R' );
(
    $chr{m}[5][1], $chr{m}[5][2], $chr{m}[5][3],
    $chr{m}[5][4], $chr{m}[5][5]
) = split( '', 'R...R' );

# letter N
# letter N
$chr{N}[0][0] = 5;    # width
$chr{N}[0][1] = 5;    # height
(
    $chr{N}[1][1], $chr{N}[1][2], $chr{N}[1][3],
    $chr{N}[1][4], $chr{N}[1][5]
) = split( '', 'R...R' );
(
    $chr{N}[2][1], $chr{N}[2][2], $chr{N}[2][3],
    $chr{N}[2][4], $chr{N}[2][5]
) = split( '', 'Rr..R' );
(
    $chr{N}[3][1], $chr{N}[3][2], $chr{N}[3][3],
    $chr{N}[3][4], $chr{N}[3][5]
) = split( '', 'R.R.R' );
(
    $chr{N}[4][1], $chr{N}[4][2], $chr{N}[4][3],
    $chr{N}[4][4], $chr{N}[4][5]
) = split( '', 'R..rR' );
(
    $chr{N}[5][1], $chr{N}[5][2], $chr{N}[5][3],
    $chr{N}[5][4], $chr{N}[5][5]
) = split( '', 'R...R' );

$chr{n}[0][0] = 5;    # width
$chr{n}[0][1] = 5;    # height
(
    $chr{n}[1][1], $chr{n}[1][2], $chr{n}[1][3],
    $chr{n}[1][4], $chr{n}[1][5]
) = split( '', '.....' );
(
    $chr{n}[2][1], $chr{n}[2][2], $chr{n}[2][3],
    $chr{n}[2][4], $chr{n}[2][5]
) = split( '', 'RRRr.' );
(
    $chr{n}[3][1], $chr{n}[3][2], $chr{n}[3][3],
    $chr{n}[3][4], $chr{n}[3][5]
) = split( '', 'R...r' );
(
    $chr{n}[4][1], $chr{n}[4][2], $chr{n}[4][3],
    $chr{n}[4][4], $chr{n}[4][5]
) = split( '', 'R...R' );
(
    $chr{n}[5][1], $chr{n}[5][2], $chr{n}[5][3],
    $chr{n}[5][4], $chr{n}[5][5]
) = split( '', 'R...R' );

# letter O
# letter O
$chr{O}[0][0] = 4;    # width
$chr{O}[0][1] = 5;    # height
( $chr{O}[1][1], $chr{O}[1][2], $chr{O}[1][3], $chr{O}[1][4] ) =  split( '', '.RR.' );
( $chr{O}[2][1], $chr{O}[2][2], $chr{O}[2][3], $chr{O}[2][4] ) =  split( '', 'R..R' );
( $chr{O}[3][1], $chr{O}[3][2], $chr{O}[3][3], $chr{O}[3][4] ) =  split( '', 'R..R' );
( $chr{O}[4][1], $chr{O}[4][2], $chr{O}[4][3], $chr{O}[4][4] ) =  split( '', 'R..R' );
( $chr{O}[5][1], $chr{O}[5][2], $chr{O}[5][3], $chr{O}[5][4] ) =  split( '', '.RR.' );

$chr{o}[0][0] = 4;    # width
$chr{o}[0][1] = 5;    # height
( $chr{o}[1][1], $chr{o}[1][2], $chr{o}[1][3], $chr{o}[1][4] ) =  split( '', '....' );
( $chr{o}[2][1], $chr{o}[2][2], $chr{o}[2][3], $chr{o}[2][4] ) =  split( '', '.RR.' );
( $chr{o}[3][1], $chr{o}[3][2], $chr{o}[3][3], $chr{o}[3][4] ) =  split( '', 'R..R' );
( $chr{o}[4][1], $chr{o}[4][2], $chr{o}[4][3], $chr{o}[4][4] ) =  split( '', 'R..R' );
( $chr{o}[5][1], $chr{o}[5][2], $chr{o}[5][3], $chr{o}[5][4] ) =  split( '', '.RR.' );

# letter P
# letter P
$chr{P}[0][0] = 4;    # width
$chr{P}[0][1] = 5;    # height
( $chr{P}[1][1], $chr{P}[1][2], $chr{P}[1][3], $chr{P}[1][4] ) =  split( '', 'RRR.' );
( $chr{P}[2][1], $chr{P}[2][2], $chr{P}[2][3], $chr{P}[2][4] ) =  split( '', 'R..r' );
( $chr{P}[3][1], $chr{P}[3][2], $chr{P}[3][3], $chr{P}[3][4] ) =  split( '', 'RRR.' );
( $chr{P}[4][1], $chr{P}[4][2], $chr{P}[4][3], $chr{P}[4][4] ) =  split( '', 'R...' );
( $chr{P}[5][1], $chr{P}[5][2], $chr{P}[5][3], $chr{P}[5][4] ) =  split( '', 'R...' );

$chr{p}[0][0] = 4;    # width
$chr{p}[0][1] = 5;    # height
( $chr{p}[1][1], $chr{p}[1][2], $chr{p}[1][3], $chr{p}[1][4] ) =  split( '', '....' );
( $chr{p}[2][1], $chr{p}[2][2], $chr{p}[2][3], $chr{p}[2][4] ) =  split( '', 'RRR.' );
( $chr{p}[3][1], $chr{p}[3][2], $chr{p}[3][3], $chr{p}[3][4] ) =  split( '', 'R..R' );
( $chr{p}[4][1], $chr{p}[4][2], $chr{p}[4][3], $chr{p}[4][4] ) =  split( '', 'RRR.' );
( $chr{p}[5][1], $chr{p}[5][2], $chr{p}[5][3], $chr{p}[5][4] ) =  split( '', 'R...' );

# letter Q
# letter Q
$chr{Q}[0][0] = 5;    # width
$chr{Q}[0][1] = 5;    # height
(
    $chr{Q}[1][1], $chr{Q}[1][2], $chr{Q}[1][3],
    $chr{Q}[1][4], $chr{Q}[1][5]
) = split( '', '.RRR.' );
(
    $chr{Q}[2][1], $chr{Q}[2][2], $chr{Q}[2][3],
    $chr{Q}[2][4], $chr{Q}[2][5]
) = split( '', 'R...R' );
(
    $chr{Q}[3][1], $chr{Q}[3][2], $chr{Q}[3][3],
    $chr{Q}[3][4], $chr{Q}[3][5]
) = split( '', 'R.r.R' );
(
    $chr{Q}[4][1], $chr{Q}[4][2], $chr{Q}[4][3],
    $chr{Q}[4][4], $chr{Q}[4][5]
) = split( '', 'R..R.' );
(
    $chr{Q}[5][1], $chr{Q}[5][2], $chr{Q}[5][3],
    $chr{Q}[5][4], $chr{Q}[5][5]
) = split( '', '.RR.r' );

$chr{q}[0][0] = 5;    # width
$chr{q}[0][1] = 5;    # height
(
    $chr{q}[1][1], $chr{q}[1][2], $chr{q}[1][3],
    $chr{q}[1][4], $chr{q}[1][5]
) = split( '', '.....' );
(
    $chr{q}[2][1], $chr{q}[2][2], $chr{q}[2][3],
    $chr{q}[2][4], $chr{q}[2][5]
) = split( '', '..RRR' );
(
    $chr{q}[3][1], $chr{q}[3][2], $chr{q}[3][3],
    $chr{q}[3][4], $chr{q}[3][5]
) = split( '', '.R..R' );
(
    $chr{q}[4][1], $chr{q}[4][2], $chr{q}[4][3],
    $chr{q}[4][4], $chr{q}[4][5]
) = split( '', '..RRR' );
(
    $chr{q}[5][1], $chr{q}[5][2], $chr{q}[5][3],
    $chr{q}[5][4], $chr{q}[5][5]
) = split( '', '....R' );

# letter R
$chr{R}[0][0] = 4;    # width
$chr{R}[0][1] = 5;    # height
( $chr{R}[1][1], $chr{R}[1][2], $chr{R}[1][3], $chr{R}[1][4] ) =  split( '', 'RRR.' );
( $chr{R}[2][1], $chr{R}[2][2], $chr{R}[2][3], $chr{R}[2][4] ) =  split( '', 'R..r' );
( $chr{R}[3][1], $chr{R}[3][2], $chr{R}[3][3], $chr{R}[3][4] ) =  split( '', 'RRR.' );
( $chr{R}[4][1], $chr{R}[4][2], $chr{R}[4][3], $chr{R}[4][4] ) =  split( '', 'R.R.' );
( $chr{R}[5][1], $chr{R}[5][2], $chr{R}[5][3], $chr{R}[5][4] ) =  split( '', 'R..R' );

$chr{r}[0][0] = 4;    # width
$chr{r}[0][1] = 5;    # height
( $chr{r}[1][1], $chr{r}[1][2], $chr{r}[1][3], $chr{r}[1][4] ) =  split( '', '....' );
( $chr{r}[2][1], $chr{r}[2][2], $chr{r}[2][3], $chr{r}[2][4] ) =  split( '', 'rRRR' );
( $chr{r}[3][1], $chr{r}[3][2], $chr{r}[3][3], $chr{r}[3][4] ) =  split( '', 'R...' );
( $chr{r}[4][1], $chr{r}[4][2], $chr{r}[4][3], $chr{r}[4][4] ) =  split( '', 'R...' );
( $chr{r}[5][1], $chr{r}[5][2], $chr{r}[5][3], $chr{r}[5][4] ) =  split( '', 'R...' );

# letter S
# letter S
$chr{S}[0][0] = 4;    # width
$chr{S}[0][1] = 5;    # height
( $chr{S}[1][1], $chr{S}[1][2], $chr{S}[1][3], $chr{S}[1][4] ) =  split( '', '.RRr' );
( $chr{S}[2][1], $chr{S}[2][2], $chr{S}[2][3], $chr{S}[2][4] ) =  split( '', 'R...' );
( $chr{S}[3][1], $chr{S}[3][2], $chr{S}[3][3], $chr{S}[3][4] ) =  split( '', '.RR.' );
( $chr{S}[4][1], $chr{S}[4][2], $chr{S}[4][3], $chr{S}[4][4] ) =  split( '', '...R' );
( $chr{S}[5][1], $chr{S}[5][2], $chr{S}[5][3], $chr{S}[5][4] ) =  split( '', 'rRR.' );

$chr{s}[0][0] = 4;    # width
$chr{s}[0][1] = 5;    # height
( $chr{s}[1][1], $chr{s}[1][2], $chr{s}[1][3], $chr{s}[1][4] ) =  split( '', '.RRr' );
( $chr{s}[2][1], $chr{s}[2][2], $chr{s}[2][3], $chr{s}[2][4] ) =  split( '', 'R...' );
( $chr{s}[3][1], $chr{s}[3][2], $chr{s}[3][3], $chr{s}[3][4] ) =  split( '', '.RR.' );
( $chr{s}[4][1], $chr{s}[4][2], $chr{s}[4][3], $chr{s}[4][4] ) =  split( '', '...R' );
( $chr{s}[5][1], $chr{s}[5][2], $chr{s}[5][3], $chr{s}[5][4] ) =  split( '', 'rRR.' );

# letter T
# letter T
$chr{T}[0][0] = 3;    # width
$chr{T}[0][1] = 5;    # height
( $chr{T}[1][1], $chr{T}[1][2], $chr{T}[1][3] ) =  split( '', 'RRR' );
( $chr{T}[2][1], $chr{T}[2][2], $chr{T}[2][3] ) =  split( '', '.R.' );
( $chr{T}[3][1], $chr{T}[3][2], $chr{T}[3][3] ) =  split( '', '.R.' );
( $chr{T}[4][1], $chr{T}[4][2], $chr{T}[4][3] ) =  split( '', '.R.' );
( $chr{T}[5][1], $chr{T}[5][2], $chr{T}[5][3] ) =  split( '', '.R.' );

$chr{t}[0][0] = 3;    # width
$chr{t}[0][1] = 5;    # height
( $chr{t}[1][1], $chr{t}[1][2], $chr{t}[1][3] ) =  split( '', '.R.' );
( $chr{t}[2][1], $chr{t}[2][2], $chr{t}[2][3] ) =  split( '', 'RRR' );
( $chr{t}[3][1], $chr{t}[3][2], $chr{t}[3][3] ) =  split( '', '.R.' );
( $chr{t}[4][1], $chr{t}[4][2], $chr{t}[4][3] ) =  split( '', '.R.' );
( $chr{t}[5][1], $chr{t}[5][2], $chr{t}[5][3] ) =  split( '', '.rR' );

# letter U
# letter U
$chr{U}[0][0] = 5;    # width
$chr{U}[0][1] = 5;    # height
(
    $chr{U}[1][1], $chr{U}[1][2], $chr{U}[1][3],
    $chr{U}[1][4], $chr{U}[1][5]
) = split( '', 'R...R' );
(
    $chr{U}[2][1], $chr{U}[2][2], $chr{U}[2][3],
    $chr{U}[2][4], $chr{U}[2][5]
) = split( '', 'R...R' );
(
    $chr{U}[3][1], $chr{U}[3][2], $chr{U}[3][3],
    $chr{U}[3][4], $chr{U}[3][5]
) = split( '', 'R...R' );
(
    $chr{U}[4][1], $chr{U}[4][2], $chr{U}[4][3],
    $chr{U}[4][4], $chr{U}[4][5]
) = split( '', 'R...R' );
(
    $chr{U}[5][1], $chr{U}[5][2], $chr{U}[5][3],
    $chr{U}[5][4], $chr{U}[5][5]
) = split( '', '.RRR.' );

$chr{u}[0][0] = 5;    # width
$chr{u}[0][1] = 5;    # height
(
    $chr{u}[1][1], $chr{u}[1][2], $chr{u}[1][3],
    $chr{u}[1][4], $chr{u}[1][5]
) = split( '', '.....' );
(
    $chr{u}[2][1], $chr{u}[2][2], $chr{u}[2][3],
    $chr{u}[2][4], $chr{u}[2][5]
) = split( '', '.R..R' );
(
    $chr{u}[3][1], $chr{u}[3][2], $chr{u}[3][3],
    $chr{u}[3][4], $chr{u}[3][5]
) = split( '', '.R..R' );
(
    $chr{u}[4][1], $chr{u}[4][2], $chr{u}[4][3],
    $chr{u}[4][4], $chr{u}[4][5]
) = split( '', '.R..R' );
(
    $chr{u}[5][1], $chr{u}[5][2], $chr{u}[5][3],
    $chr{u}[5][4], $chr{u}[5][5]
) = split( '', '..RRr' );

# letter V
# letter V
$chr{V}[0][0] = 4;    # width
$chr{V}[0][1] = 5;    # height
( $chr{V}[1][1], $chr{V}[1][2], $chr{V}[1][3], $chr{V}[1][4] ) =  split( '', 'R..R' );
( $chr{V}[2][1], $chr{V}[2][2], $chr{V}[2][3], $chr{V}[2][4] ) =  split( '', 'R..R' );
( $chr{V}[3][1], $chr{V}[3][2], $chr{V}[3][3], $chr{V}[3][4] ) =  split( '', 'R..R' );
( $chr{V}[4][1], $chr{V}[4][2], $chr{V}[4][3], $chr{V}[4][4] ) =  split( '', '.RR.' );
( $chr{V}[5][1], $chr{V}[5][2], $chr{V}[5][3], $chr{V}[5][4] ) =  split( '', '.rr.' );

$chr{v}[0][0] = 4;    # width
$chr{v}[0][1] = 5;    # height
( $chr{v}[1][1], $chr{v}[1][2], $chr{v}[1][3], $chr{v}[1][4] ) =  split( '', '....' );
( $chr{v}[2][1], $chr{v}[2][2], $chr{v}[2][3], $chr{v}[2][4] ) =  split( '', '....' );
( $chr{v}[3][1], $chr{v}[3][2], $chr{v}[3][3], $chr{v}[3][4] ) =  split( '', 'R..R' );
( $chr{v}[4][1], $chr{v}[4][2], $chr{v}[4][3], $chr{v}[4][4] ) =  split( '', '.R.R' );
( $chr{v}[5][1], $chr{v}[5][2], $chr{v}[5][3], $chr{v}[5][4] ) =  split( '', '..R.' );

# letter W
# letter W
$chr{W}[0][0] = 5;    # width
$chr{W}[0][1] = 5;    # height
(
    $chr{W}[1][1], $chr{W}[1][2], $chr{W}[1][3],
    $chr{W}[1][4], $chr{W}[1][5]
) = split( '', 'R...R' );
(
    $chr{W}[2][1], $chr{W}[2][2], $chr{W}[2][3],
    $chr{W}[2][4], $chr{W}[2][5]
) = split( '', 'R...R' );
(
    $chr{W}[3][1], $chr{W}[3][2], $chr{W}[3][3],
    $chr{W}[3][4], $chr{W}[3][5]
) = split( '', 'R.r.R' );
(
    $chr{W}[4][1], $chr{W}[4][2], $chr{W}[4][3],
    $chr{W}[4][4], $chr{W}[4][5]
) = split( '', 'R.R.R' );
(
    $chr{W}[5][1], $chr{W}[5][2], $chr{W}[5][3],
    $chr{W}[5][4], $chr{W}[5][5]
) = split( '', '.R.R.' );

$chr{w}[0][0] = 5;    # width
$chr{w}[0][1] = 5;    # height
(
    $chr{w}[1][1], $chr{w}[1][2], $chr{w}[1][3],
    $chr{w}[1][4], $chr{w}[1][5]
) = split( '', '.....' );
(
    $chr{w}[2][1], $chr{w}[2][2], $chr{w}[2][3],
    $chr{w}[2][4], $chr{w}[2][5]
) = split( '', '.....' );
(
    $chr{w}[3][1], $chr{w}[3][2], $chr{w}[3][3],
    $chr{w}[3][4], $chr{w}[3][5]
) = split( '', 'R.r.R' );
(
    $chr{w}[4][1], $chr{w}[4][2], $chr{w}[4][3],
    $chr{w}[4][4], $chr{w}[4][5]
) = split( '', 'R.R.R' );
(
    $chr{w}[5][1], $chr{w}[5][2], $chr{w}[5][3],
    $chr{w}[5][4], $chr{w}[5][5]
) = split( '', '.R.R.' );

# letter X
# letter X
$chr{X}[0][0] = 5;    # width
$chr{X}[0][1] = 5;    # height
(
    $chr{X}[1][1], $chr{X}[1][2], $chr{X}[1][3],
    $chr{X}[1][4], $chr{X}[1][5]
) = split( '', 'R...R' );
(
    $chr{X}[2][1], $chr{X}[2][2], $chr{X}[2][3],
    $chr{X}[2][4], $chr{X}[2][5]
) = split( '', '.R.R.' );
(
    $chr{X}[3][1], $chr{X}[3][2], $chr{X}[3][3],
    $chr{X}[3][4], $chr{X}[3][5]
) = split( '', '..R..' );
(
    $chr{X}[4][1], $chr{X}[4][2], $chr{X}[4][3],
    $chr{X}[4][4], $chr{X}[4][5]
) = split( '', '.R.R.' );
(
    $chr{X}[5][1], $chr{X}[5][2], $chr{X}[5][3],
    $chr{X}[5][4], $chr{X}[5][5]
) = split( '', 'R...R' );

$chr{x}[0][0] = 5;    # width
$chr{x}[0][1] = 5;    # height
(
    $chr{x}[1][1], $chr{x}[1][2], $chr{x}[1][3],
    $chr{x}[1][4], $chr{x}[1][5]
) = split( '', '.....' );
(
    $chr{x}[2][1], $chr{x}[2][2], $chr{x}[2][3],
    $chr{x}[2][4], $chr{x}[2][5]
) = split( '', '.....' );
(
    $chr{x}[3][1], $chr{x}[3][2], $chr{x}[3][3],
    $chr{x}[3][4], $chr{x}[3][5]
) = split( '', '.R..R' );
(
    $chr{x}[4][1], $chr{x}[4][2], $chr{x}[4][3],
    $chr{x}[4][4], $chr{x}[4][5]
) = split( '', '..rr.' );
(
    $chr{x}[5][1], $chr{x}[5][2], $chr{x}[5][3],
    $chr{x}[5][4], $chr{x}[5][5]
) = split( '', '.R..R' );

# letter Y
# letter Y
$chr{Y}[0][0] = 5;    # width
$chr{Y}[0][1] = 5;    # height
(
    $chr{Y}[1][1], $chr{Y}[1][2], $chr{Y}[1][3],
    $chr{Y}[1][4], $chr{Y}[1][5]
) = split( '', 'R...R' );
(
    $chr{Y}[2][1], $chr{Y}[2][2], $chr{Y}[2][3],
    $chr{Y}[2][4], $chr{Y}[2][5]
) = split( '', '.R.R.' );
(
    $chr{Y}[3][1], $chr{Y}[3][2], $chr{Y}[3][3],
    $chr{Y}[3][4], $chr{Y}[3][5]
) = split( '', '..R..' );
(
    $chr{Y}[4][1], $chr{Y}[4][2], $chr{Y}[4][3],
    $chr{Y}[4][4], $chr{Y}[4][5]
) = split( '', '..R..' );
(
    $chr{Y}[5][1], $chr{Y}[5][2], $chr{Y}[5][3],
    $chr{Y}[5][4], $chr{Y}[5][5]
) = split( '', '..R..' );

$chr{y}[0][0] = 5;    # width
$chr{y}[0][1] = 5;    # height
(
    $chr{y}[1][1], $chr{y}[1][2], $chr{y}[1][3],
    $chr{y}[1][4], $chr{y}[1][5]
) = split( '', '.....' );
(
    $chr{y}[2][1], $chr{y}[2][2], $chr{y}[2][3],
    $chr{y}[2][4], $chr{y}[2][5]
) = split( '', '.R..R' );
(
    $chr{y}[3][1], $chr{y}[3][2], $chr{y}[3][3],
    $chr{y}[3][4], $chr{y}[3][5]
) = split( '', '..R.R' );
(
    $chr{y}[4][1], $chr{y}[4][2], $chr{y}[4][3],
    $chr{y}[4][4], $chr{y}[4][5]
) = split( '', '...R.' );
(
    $chr{y}[5][1], $chr{y}[5][2], $chr{y}[5][3],
    $chr{y}[5][4], $chr{y}[5][5]
) = split( '', '.rR..' );

# letter Z
# letter Z
$chr{Z}[0][0] = 4;    # width
$chr{Z}[0][1] = 5;    # height
( $chr{Z}[1][1], $chr{Z}[1][2], $chr{Z}[1][3], $chr{Z}[1][4] ) =  split( '', 'RRRR' );
( $chr{Z}[2][1], $chr{Z}[2][2], $chr{Z}[2][3], $chr{Z}[2][4] ) =  split( '', '...R' );
( $chr{Z}[3][1], $chr{Z}[3][2], $chr{Z}[3][3], $chr{Z}[3][4] ) =  split( '', '.RR.' );
( $chr{Z}[4][1], $chr{Z}[4][2], $chr{Z}[4][3], $chr{Z}[4][4] ) =  split( '', 'R...' );
( $chr{Z}[5][1], $chr{Z}[5][2], $chr{Z}[5][3], $chr{Z}[5][4] ) =  split( '', 'RRRR' );

$chr{z}[0][0] = 4;    # width
$chr{z}[0][1] = 5;    # height
( $chr{z}[1][1], $chr{z}[1][2], $chr{z}[1][3], $chr{z}[1][4] ) =  split( '', '....' );
( $chr{z}[2][1], $chr{z}[2][2], $chr{z}[2][3], $chr{z}[2][4] ) =  split( '', '.RRR' );
( $chr{z}[3][1], $chr{z}[3][2], $chr{z}[3][3], $chr{z}[3][4] ) =  split( '', '...R' );
( $chr{z}[4][1], $chr{z}[4][2], $chr{z}[4][3], $chr{z}[4][4] ) =  split( '', '..R.' );
( $chr{z}[5][1], $chr{z}[5][2], $chr{z}[5][3], $chr{z}[5][4] ) =  split( '', '.RRR' );

# number 0
$chr{0}[0][0] = 4;    # width
$chr{0}[0][1] = 5;    # height
( $chr{0}[1][1], $chr{0}[1][2], $chr{0}[1][3], $chr{0}[1][4] ) =  split( '', '.RR.' );
( $chr{0}[2][1], $chr{0}[2][2], $chr{0}[2][3], $chr{0}[2][4] ) =  split( '', 'R..R' );
( $chr{0}[3][1], $chr{0}[3][2], $chr{0}[3][3], $chr{0}[3][4] ) =  split( '', 'R..R' );
( $chr{0}[4][1], $chr{0}[4][2], $chr{0}[4][3], $chr{0}[4][4] ) =  split( '', 'R..R' );
( $chr{0}[5][1], $chr{0}[5][2], $chr{0}[5][3], $chr{0}[5][4] ) =  split( '', '.RR.' );

# number 1
$chr{1}[0][0] = 4;    # width
$chr{1}[0][1] = 5;    # height
( $chr{1}[1][1], $chr{1}[1][2], $chr{1}[1][3], $chr{1}[1][4] ) =  split( '', '.RR.' );
( $chr{1}[2][1], $chr{1}[2][2], $chr{1}[2][3], $chr{1}[2][4] ) =  split( '', '..R.' );
( $chr{1}[3][1], $chr{1}[3][2], $chr{1}[3][3], $chr{1}[3][4] ) =  split( '', '..R.' );
( $chr{1}[4][1], $chr{1}[4][2], $chr{1}[4][3], $chr{1}[4][4] ) =  split( '', '..R.' );
( $chr{1}[5][1], $chr{1}[5][2], $chr{1}[5][3], $chr{1}[5][4] ) =  split( '', '.RRR' );

# number 2
$chr{2}[0][0] = 4;    # width
$chr{2}[0][1] = 5;    # height
( $chr{2}[1][1], $chr{2}[1][2], $chr{2}[1][3], $chr{2}[1][4] ) =  split( '', '.RR.' );
( $chr{2}[2][1], $chr{2}[2][2], $chr{2}[2][3], $chr{2}[2][4] ) =  split( '', 'R..R' );
( $chr{2}[3][1], $chr{2}[3][2], $chr{2}[3][3], $chr{2}[3][4] ) =  split( '', '..R.' );
( $chr{2}[4][1], $chr{2}[4][2], $chr{2}[4][3], $chr{2}[4][4] ) =  split( '', '.R..' );
( $chr{2}[5][1], $chr{2}[5][2], $chr{2}[5][3], $chr{2}[5][4] ) =  split( '', 'RRRR' );

#number 3
$chr{3}[0][0] = 4;    # width
$chr{3}[0][1] = 5;    # height
( $chr{3}[1][1], $chr{3}[1][2], $chr{3}[1][3], $chr{3}[1][4] ) =  split( '', 'rRR.' );
( $chr{3}[2][1], $chr{3}[2][2], $chr{3}[2][3], $chr{3}[2][4] ) =  split( '', '...R' );
( $chr{3}[3][1], $chr{3}[3][2], $chr{3}[3][3], $chr{3}[3][4] ) =  split( '', '.rRR' );
( $chr{3}[4][1], $chr{3}[4][2], $chr{3}[4][3], $chr{3}[4][4] ) =  split( '', '...R' );
( $chr{3}[5][1], $chr{3}[5][2], $chr{3}[5][3], $chr{3}[5][4] ) =  split( '', 'rRR.' );

# number 4
$chr{4}[0][0] = 4;    # width
$chr{4}[0][1] = 5;    # height
( $chr{4}[1][1], $chr{4}[1][2], $chr{4}[1][3], $chr{4}[1][4] ) =  split( '', 'R.R.' );
( $chr{4}[2][1], $chr{4}[2][2], $chr{4}[2][3], $chr{4}[2][4] ) =  split( '', 'R.R.' );
( $chr{4}[3][1], $chr{4}[3][2], $chr{4}[3][3], $chr{4}[3][4] ) =  split( '', 'RRRR' );
( $chr{4}[4][1], $chr{4}[4][2], $chr{4}[4][3], $chr{4}[4][4] ) =  split( '', '..R.' );
( $chr{4}[5][1], $chr{4}[5][2], $chr{4}[5][3], $chr{4}[5][4] ) =  split( '', '..R.' );

# number 5
$chr{5}[0][0] = 4;    # width
$chr{5}[0][1] = 5;    # height
( $chr{5}[1][1], $chr{5}[1][2], $chr{5}[1][3], $chr{5}[1][4] ) =  split( '', 'rRRR' );
( $chr{5}[2][1], $chr{5}[2][2], $chr{5}[2][3], $chr{5}[2][4] ) =  split( '', 'R...' );
( $chr{5}[3][1], $chr{5}[3][2], $chr{5}[3][3], $chr{5}[3][4] ) =  split( '', '.RR.' );
( $chr{5}[4][1], $chr{5}[4][2], $chr{5}[4][3], $chr{5}[4][4] ) =  split( '', '...r' );
( $chr{5}[5][1], $chr{5}[5][2], $chr{5}[5][3], $chr{5}[5][4] ) =  split( '', 'RRR.' );

# number 6
$chr{6}[0][0] = 4;    # width
$chr{6}[0][1] = 5;    # height
( $chr{6}[1][1], $chr{6}[1][2], $chr{6}[1][3], $chr{6}[1][4] ) =  split( '', '.R..' );
( $chr{6}[2][1], $chr{6}[2][2], $chr{6}[2][3], $chr{6}[2][4] ) =  split( '', 'R...' );
( $chr{6}[3][1], $chr{6}[3][2], $chr{6}[3][3], $chr{6}[3][4] ) =  split( '', 'RRR.' );
( $chr{6}[4][1], $chr{6}[4][2], $chr{6}[4][3], $chr{6}[4][4] ) =  split( '', 'R..R' );
( $chr{6}[5][1], $chr{6}[5][2], $chr{6}[5][3], $chr{6}[5][4] ) =  split( '', '.RR.' );

# number 7
$chr{7}[0][0] = 4;    # width
$chr{7}[0][1] = 5;    # height
( $chr{7}[1][1], $chr{7}[1][2], $chr{7}[1][3], $chr{7}[1][4] ) =  split( '', 'RRRR' );
( $chr{7}[2][1], $chr{7}[2][2], $chr{7}[2][3], $chr{7}[2][4] ) =  split( '', '...R' );
( $chr{7}[3][1], $chr{7}[3][2], $chr{7}[3][3], $chr{7}[3][4] ) =  split( '', '..R.' );
( $chr{7}[4][1], $chr{7}[4][2], $chr{7}[4][3], $chr{7}[4][4] ) =  split( '', '..R.' );
( $chr{7}[5][1], $chr{7}[5][2], $chr{7}[5][3], $chr{7}[5][4] ) =  split( '', '..R.' );

# number 8
$chr{8}[0][0] = 4;    # width
$chr{8}[0][1] = 5;    # height
( $chr{8}[1][1], $chr{8}[1][2], $chr{8}[1][3], $chr{8}[1][4] ) =  split( '', '.RR.' );
( $chr{8}[2][1], $chr{8}[2][2], $chr{8}[2][3], $chr{8}[2][4] ) =  split( '', 'R..R' );
( $chr{8}[3][1], $chr{8}[3][2], $chr{8}[3][3], $chr{8}[3][4] ) =  split( '', '.RR.' );
( $chr{8}[4][1], $chr{8}[4][2], $chr{8}[4][3], $chr{8}[4][4] ) =  split( '', 'R..R' );
( $chr{8}[5][1], $chr{8}[5][2], $chr{8}[5][3], $chr{8}[5][4] ) =  split( '', '.RR.' );

# number 9
$chr{9}[0][0] = 4;    # width
$chr{9}[0][1] = 5;    # height
( $chr{9}[1][1], $chr{9}[1][2], $chr{9}[1][3], $chr{9}[1][4] ) =  split( '', '.RR.' );
( $chr{9}[2][1], $chr{9}[2][2], $chr{9}[2][3], $chr{9}[2][4] ) =  split( '', 'R..R' );
( $chr{9}[3][1], $chr{9}[3][2], $chr{9}[3][3], $chr{9}[3][4] ) =  split( '', '.RRR' );
( $chr{9}[4][1], $chr{9}[4][2], $chr{9}[4][3], $chr{9}[4][4] ) =  split( '', '...R' );
( $chr{9}[5][1], $chr{9}[5][2], $chr{9}[5][3], $chr{9}[5][4] ) =  split( '', '..R.' );

# letter 'space'
$chr{' '}[0][0] = 4;    # width
$chr{' '}[0][1] = 5;    # height
(
    $chr{' '}[1][1], $chr{' '}[1][2],
    $chr{' '}[1][3], $chr{' '}[1][4]
) = split( '', '....' );
(
    $chr{' '}[2][1], $chr{' '}[2][2],
    $chr{' '}[2][3], $chr{' '}[2][4]
) = split( '', '....' );
(
    $chr{' '}[3][1], $chr{' '}[3][2],
    $chr{' '}[3][3], $chr{' '}[3][4]
) = split( '', '....' );
(
    $chr{' '}[4][1], $chr{' '}[4][2],
    $chr{' '}[4][3], $chr{' '}[4][4]
) = split( '', '....' );
(
    $chr{' '}[5][1], $chr{' '}[5][2],
    $chr{' '}[5][3], $chr{' '}[5][4]
) = split( '', '....' );

# letter '.'
$chr{'.'}[0][0] = 1;    # width
$chr{'.'}[0][1] = 5;    # height
 $chr{'.'}[1][1]  =  '.';
 $chr{'.'}[2][1]  =  '.';
 $chr{'.'}[3][1]  =  '.';
 $chr{'.'}[4][1]  =  '.';
 $chr{'.'}[5][1]  =  'R';

# letter 'percentage'
$chr{'%'}[0][0] = 5;    # width
$chr{'%'}[0][1] = 5;    # height
(
    $chr{'%'}[1][1], $chr{'%'}[1][2], $chr{'%'}[1][3],
    $chr{'%'}[1][4], $chr{'%'}[1][5]
) = split( '', 'r...R' );
(
    $chr{'%'}[2][1], $chr{'%'}[2][2], $chr{'%'}[2][3],
    $chr{'%'}[2][4], $chr{'%'}[2][5]
) = split( '', '...R.' );
(
    $chr{'%'}[3][1], $chr{'%'}[3][2], $chr{'%'}[3][3],
    $chr{'%'}[3][4], $chr{'%'}[3][5]
) = split( '', '..R..' );
(
    $chr{'%'}[4][1], $chr{'%'}[4][2], $chr{'%'}[4][3],
    $chr{'%'}[4][4], $chr{'%'}[4][5]
) = split( '', '.R...' );
(
    $chr{'%'}[5][1], $chr{'%'}[5][2], $chr{'%'}[5][3],
    $chr{'%'}[5][4], $chr{'%'}[5][5]
) = split( '', 'R...r' );

# ======================================
#  MAIN
# ======================================

# setup the buffer
# buffer is the display window (5x10) and the remaining message phrase buffer to the right
# That is, buffer = [display window][message text to the right to scroll in leftwards]

while (1) {
    my @buffer;

    my $buffercols = 10;    # base 'output window' width is 10.
    my $bufferrows = 5;     # base 'output window' height is 5.

    #start by setting the a 'blank display window' in buffer.
    for ( my $col = 0 ; $col <= ( $buffercols - 1 ) ; $col++ ) {
        for ( my $row = 1 ; $row <= 5 ; $row++ ) {
            $buffer[$row][$col] = '.';
        }
    }

  # cycle through the message phrase and calculate length and set buffer values.

#set column counter to the next cab off the rank, which is 11 after the window length;

    # -------------------------------
    # Get current weather information
    # -------------------------------

    # this uses the url to a json of of data for a specific Australian location.

    my $lwpcurl = LWP::Curl->new();
    my $content = $lwpcurl->get( $get_url, $referer );
    my $decoded = decode_json($content);

    # Extract the data items we want - do note that the json has lots more data to play with.

    $bom{name}     = $decoded->{'observations'}{'data'}[0]{'name'};
    $bom{air_temp} = $decoded->{'observations'}{'data'}[0]{'air_temp'};
    $bom{rel_hum}  = $decoded->{'observations'}{'data'}[0]{'rel_hum'};

    # Construct the phrase we wish to scroll to our lights

    my $phrase = "$bom{air_temp} $bom{rel_hum}%";


    my $column = 10;    # column is a tracking variable as we fill the buffer array that has 0 index start

    foreach my $i ( split( '', $phrase ) ) {

        $buffercols = $buffercols + $chr{$i}[0][0] + 2;  #include +2 for spacing letters

        #add the letter into the buffer

        for ( my $col = 1 ; $col <= $chr{$i}[0][0] ; $col++ ) {
            for ( my $row = 1 ; $row <= 5 ; $row++ ) {
                $buffer[$row][$column] = $chr{$i}[$row][$col];
            }
            $column++;
        }

        # Add a letter spacer into the buffer

        for ( my $row = 1 ; $row <= 5 ; $row++ ) {
            $buffer[$row][$column] = '.';
        }
        $column++;

        for ( my $row = 1 ; $row <= 5 ; $row++ ) {
            $buffer[$row][$column] = '.';
        }
        $column++;
    }

    my $numcolumns = $buffercols;

    #========================
    # ON SCREEN CROSS CHECK - optional
    #========================

    # Print out the buffer to the terminal screen = simulate the message the lights will display

if ($debug eq 'yes') {
    print "\n";
    print "num columns = $numcolumns : columns = $column\n\n";

    for ( my $r = 1 ; $r <= 5 ; $r++ ) {
        for ( my $c = 0 ; $c < $numcolumns ; $c++ ) {

            print "$r:$c:$buffer[$r][$c]:";
        }
        print "#\n";
    }
    print "\n";
    print "\n";
}
    #=========================
    # MAIN DISPLAY LOOP
    #========================
    # @string is our string of Holiday lights

    my @string;

    my $loop_start_time = time;

    while ( ( time - $loop_start_time ) < 600 ) {

# ASSIGN light values to the Holiday lights string;
# This is done by drawing the relevant values in the buffer in the relevant order.

# @buffer is the logical display matrix whereas sting is linear - so needs to be mapped

        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            $string[ 50 - $t ] = $buffer[1][$t];
            $string[ 31 + $t ] = $buffer[2][$t];
            $string[ 30 - $t ] = $buffer[3][$t];
            $string[ 11 + $t ] = $buffer[4][$t];
            $string[ 10 - $t ] = $buffer[5][$t];
        }

# grab the first column of lights values, we need to shunt them back to the end.

        my @buff;

        $buff[1] = $buffer[1][0];
        $buff[2] = $buffer[2][0];
        $buff[3] = $buffer[3][0];
        $buff[4] = $buffer[4][0];
        $buff[5] = $buffer[5][0];

        for ( my $t = 0 ; $t < $column ; $t++ ) {
            $buffer[1][$t] = $buffer[1][ $t + 1 ];
            $buffer[2][$t] = $buffer[2][ $t + 1 ];
            $buffer[3][$t] = $buffer[3][ $t + 1 ];
            $buffer[4][$t] = $buffer[4][ $t + 1 ];
            $buffer[5][$t] = $buffer[5][ $t + 1 ];
        }

        $buffer[1][$numcolumns-1] = $buff[1];
        $buffer[2][$numcolumns-1] = $buff[2];
        $buffer[3][$numcolumns-1] = $buff[3];
        $buffer[4][$numcolumns-1] = $buff[4];
        $buffer[5][$numcolumns-1] = $buff[5];

        #buffer updated, send to the Holiday string;
        # sending as a UDP datagram

        # first 10 characters null
        my $stringUDP = pack( 'C*', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

        # then cycle through each light

        for ( my $light = 1 ; $light <= 50 ; $light++ ) {

            my $hexcolour = $colours{ $string[$light] };

         #usleep 1000000;
         ($debug eq 'no') or print "light: $light string[light]: $string[$light] hex:$hexcolour\n";
            my $dec_num1 = sprintf( "%d", hex( substr( $hexcolour, 0, 2 ) ) );
            my $dec_num2 = sprintf( "%d", hex( substr( $hexcolour, 2, 2 ) ) );
            my $dec_num3 = sprintf( "%d", hex( substr( $hexcolour, 4, 2 ) ) );
            $stringUDP .= pack( 'C*', $dec_num1, $dec_num2, $dec_num3 );

            #print $stringUDP;
        }

        $sock->send($stringUDP) or die "Send error: $!\n";
        usleep $scroll_delay;

if ($debug eq 'yes') {
        print "=======================\n";
        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            print $string[ 50 - $t ] = $buffer[1][$t];
        }
        print "\n";
        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            print $string[ 31 + $t ] = $buffer[2][$t];
        }
        print "\n";
        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            print $string[ 30 - $t ] = $buffer[3][$t];
        }
        print "\n";
        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            print $string[ 11 + $t ] = $buffer[4][$t];
        }
        print "\n";
        for ( my $t = 0 ; $t <= 9 ; $t++ ) {
            print $string[ 10 - $t ] = $buffer[5][$t];
        }
        print "\n";
        print "=======================\n";
	}
    }
}
exit;

