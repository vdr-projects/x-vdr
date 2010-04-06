#!/usr/bin/perl
#
# Shutdownscript extb-poweroff.pl for extb-Board
#
# adapt by Andreas Brachold <vdr04-at-deltab.de>
# based on Shutdownscript for ACPI by Thomas Koch <tom-at-linvdr.org>
#
use strict;
use POSIX qw(strftime sprintf localtime time);
use Time::Local;

################################################################################
# Our readed config file, to overload the default values
my $CONFIGFILE = "/etc/extb/extb-poweroff.conf";  

################################################################################
### Defaultvalues, for adjust you can use /etc/extb/extb-poweroff.conf #########
################################################################################
my %Config;
# How many Seconds should poweron before timer started
$Config{"STARTUPMARGIN"} = 300;
# How many second need your system for Shutdown, extb-timer run not until power is down
$Config{"SHUTDOWNDURATION"} = 15; 	
# How many seconds can drift the timer on one day
$Config{"DAILYOFFSET"} = 0;
# Wake avery night at 02:00 for e.g. EPG Scan
$Config{"WAKEFOREPGSCAN"} = 0;
# if you wish to use external script to stop shutdown, maybe adjust name
$Config{"CHECKSCRIPT"} = "";
# Send Macro before Shutdown "" for nothing, "M2" for 
$Config{"RCSEND_VIDEOOFF"} = "";
# shutdown command, on small system like LINVDR use "/bin/busybox poweroff"
$Config{"SHUTDOWN"} = "/sbin/shutdown -h now";
# Which command should call to transfer IR Codes to extb-board rc or irsend
$Config{"RCCMD"} = "/usr/bin/irsend";
# required commando to send messages to VDR, maybe adjust path
$Config{"SVDRSEND_PL"} = "/usr/bin/svdrpsend.pl";
# Should set hardware clock through ext-poweroff.pl, set it to "hwclock -w"
$Config{"SETCLOCK"} = "";

################################################################################
# Internal Limits and change only if you know what you do
# How long should extb sleep, eg only 1 Day, 1 Week , 1 Month ... if used timer delay bigger
my $SLEEPLIMIT = 0xFFFFFF; # FFFFFF are 2^24 * 0.524288 Sek = 8.796.093 Sek = 146.601 Min = 101,8 Days
# Duration of one counter step inside the PIC,  4MHz are 0.524288 sek
my $PICTICKER = 0.524288;  
# Dump any messages on Screen and don't go powerdown
my $DEBUG = 0;

################################################################################
my ($STARTUPMARGIN,$SHUTDOWNDURATION,$DAILYOFFSET,$WAKEFOREPGSCAN,$CHECKSCRIPT);
my ($RCSEND_VIDEOOFF,$SHUTDOWN,$RCCMD,$SVDRSEND_PL,$SETCLOCK);

################################################################################
# Dump some Debugmessages
sub dprint {
  $_ = join("", @_);
  chomp;
  print "$_\n" if($DEBUG);
}

################################################################################
# Run external user script
sub CheckScript {
	if ($CHECKSCRIPT && -x $CHECKSCRIPT) {
      my($Next, $Delta, $Channel, $Recording, $UserShutdown) = @ARGV;
      my $msg = `$CHECKSCRIPT $Next $Delta $Channel \"$Recording\" $UserShutdown`;
    if($msg) {
        SendMsg($msg);
        dprint("Shutdown abgebrochen");
        exit 1;
    }
  }
}

################################################################################
# Execute external command
sub ExecCmd {
  my $cmd = shift;
  dprint("Exec: ".$cmd);
  system( $cmd ) if(!$DEBUG);
}

################################################################################
# send message to VDR
sub SendMsg {
  my $msg = shift;
  dprint("SendMsg: ".$msg);
  # Hmm, nix funktioniert ...
  #`$SVDRSEND_PL MESG $msg &> /dev/null`;
  #`echo -e "MESG $msg\nQUIT" | nc 127.0.0.1 2001 &> /dev/null`;
  # nur per atd geht es ...
  `echo '$SVDRSEND_PL MESG "$msg" &> /dev/null' | at now &> /dev/null`;
}

################################################################################
# Turn Video off, or send other RC Code to extb-board
sub VideoOff {
  if($RCSEND_VIDEOOFF) {
  ExecCmd( sprintf("%s send_once EXTB_TX %s",$RCCMD, $RCSEND_VIDEOOFF));
  }
}

################################################################################
# Set clock, if your need it
sub setTime {
  if($SETCLOCK) {
      ExecCmd($SETCLOCK); 
  }
}  

################################################################################
# Set Alarm, your will need it ;-)
sub setAlarm {
  my $Next = shift;
  setTime();  
  dprint("Next event at ", strftime("%d.%m.%Y %H:%M:%S", localtime($Next)));
  dprint("Programming wakeup at ", strftime("%d.%m.%Y %H:%M:%S", localtime($Next-$STARTUPMARGIN)));

  # Get difference between now and next timer
  my $delta = (($Next - ($STARTUPMARGIN + $SHUTDOWNDURATION)) - time());
  if($delta < $STARTUPMARGIN)
  {
    SendMsg("Weckzeit zu kurz ".$delta." Sekunden");
    dprint("Shutdown canceld");
    exit 1;
  }

  VideoOff(); 

  dprint("Wakeup at ",int($delta), " Seconds");
  # Adjust drift crystal with 6 Sec on one day
  if( $DAILYOFFSET > 0) {
    $delta -= ($delta / 86400)*$DAILYOFFSET; # 24h*60m*60s
    dprint("Adjusted Wakeup at ",int($delta), " Seconds");
  }


  # Adjust for PIC Counterticks
  my $valueint =  $delta / $PICTICKER;
  dprint("PIC value ", int($valueint), " PicTics");

  # Userclipping
  if(int($valueint) > $SLEEPLIMIT){ $valueint = $SLEEPLIMIT;  }
  # Systemclipping
  if(int($valueint) > 0xFFFFFF)   { $valueint = 0xFFFFFF;     }

  # integer to hex ( 6 Characters)
  my $valuehex = uc(sprintf("%06x",int($valueint)));
  # insert between all hex character a placeholder "space"
  my $valuestring = "";
  for(my $i = 0; $i <= length($valuehex); $i+=1){
  $valuestring = $valuestring.substr($valuehex,$i,1)." ";
  };

  # Execute rc to send new timer
  ExecCmd( sprintf("%s send_once EXTB_TX %s",$RCCMD,$valuestring ));
}

################################################################################
# Execute System shutdown
sub PowerOff {
  ExecCmd( $SHUTDOWN );
  exit 0;
}

################################################################################
# Get time from next day at 02:00
sub NextTwoOclock {
  my $now = time();
  # Array-Format: ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
  my @today = localtime($now);
  @today[0..2] = (0, 0, 2);

  # get today 2:00 in seconds since epoc
  my $TwoOclock = timelocal(@today);
  
  # Check: Is today 2:00 in future or past?
  if($now < $TwoOclock) {
    # Today two oclock is in future
    return $TwoOclock;
  } else {
    # We're past two oclock, next two oclock is tomorrow (+86400s)
    return $TwoOclock+86400;
  }
}

################################################################################
# lookup for configuration file
if ($CONFIGFILE && -e $CONFIGFILE) {
    open(CONFIG, "< $CONFIGFILE") or die "can't open $CONFIGFILE: $!";
    while (<CONFIG>) {
    chomp;                  # no newline
    s/#.*//;                # no comments
    s/^\s+//;               # no leading white
    s/\s+$//;               # no trailing white
    next unless length;     # anything left?
    my ($var, $value) = split(/\s*=\s*/, $_, 2);
    $Config{$var} = $value;
    
    dprint("Config{\"$var\"} = ".$value);
    }
} 

################################################################################
# Set readed or default configuration
$STARTUPMARGIN = $Config{"STARTUPMARGIN"};
$SHUTDOWNDURATION = $Config{"SHUTDOWNDURATION"}; 	
$DAILYOFFSET  = $Config{"DAILYOFFSET"};
$WAKEFOREPGSCAN  = $Config{"WAKEFOREPGSCAN"};
$CHECKSCRIPT  = $Config{"CHECKSCRIPT"};
$RCSEND_VIDEOOFF  = $Config{"RCSEND_VIDEOOFF"};
$SHUTDOWN  = $Config{"SHUTDOWN"};
$RCCMD = $Config{"RCCMD"};
$SVDRSEND_PL = $Config{"SVDRSEND_PL"};
$SETCLOCK = $Config{"SETCLOCK"};

################################################################################
# Main task
# 
my $TwoOclock = NextTwoOclock();

if(scalar(@ARGV)) {
  # called from vdr
  die "Wrong parameter count\n" if(scalar(@ARGV) != 5);

  CheckScript();
  
  my($Next, $Delta, $Channel, $Recording, $UserShutdown) = @ARGV;
  # dprint ("$Next, $Delta, $Channel, $Recording, $UserShutdown");
  # find out: Next start at 2:00 or at next timer?
  if(($Next) && (!($WAKEFOREPGSCAN) || ($Next < $TwoOclock))) {
    setAlarm($Next);
    } else {
      if($WAKEFOREPGSCAN) {
          setAlarm($TwoOclock);
      }
      else {
          VideoOff();
      }
    }
    PowerOff();
  } else {
  # called from cmdline
  my $next = `$SVDRSEND_PL next abs`;
  if($next =~ /550 No active timers/) {
    if($WAKEFOREPGSCAN) {
      # start every day at 2:00 local time for EPG update & Co.
      setAlarm($TwoOclock);
    }
    else {
      VideoOff();
    }
    PowerOff();
  } elsif($next =~ /250 \d+ (\d+)/) {
    # find out: Next start at 2:00 or at next timer?
    if(($1 < $TwoOclock) || !($WAKEFOREPGSCAN)) {
      setAlarm($1);
    } else {
        if($WAKEFOREPGSCAN) {
            setAlarm($TwoOclock);
        }
        else {
        VideoOff();
        }
    }
    PowerOff();
  } else {
    print "HELP! What to do? ($next)\n";
  }
  exit 1;
}
