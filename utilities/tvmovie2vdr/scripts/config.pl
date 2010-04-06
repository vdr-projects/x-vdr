#!/usr/bin/perl


# Settings
$channelsfile = "/var/lib/vdr/channels.conf"; 	# path to channels-datei
$epgfile = "/var/lib/vdr/epgdata/epg.data";			# path to epg-file
$days2download = 7;			# max. 8 days tvmovie, max 21-28 days tvinfo
$clearEPG = 1;				# clear EPG before inserting them into VDR ? 
                                        # 1=true/0=false
$downloadprefix = "downloadfiles/";	# where to write downloaded files?
$updateprefix = "downloadupdatefiles/"; # where to write downloaded updatefiles?
                                        # use a different folder!
$cleanupoldfiles = 1;			# clean "old" cache-files ?
                                        # 1=true/0=false
$networktries = 1;			# number of retries when there are
					# networkproblems
$abortonnetwork = 0;			# abort, if there are
					# networkproblems?
$networktimeout = 60;			# networktimeout in seconds.

$wantbottomflags = 1;			# you want special flags like
$wanttopflags = 1;			# [DolbyDigital] in the EPG ?
					# 1=true/0=false
$wantosd = 0;				# do you want the progress on OSD?

our $writeimages = 1;   		# 1=true/0=false, only available for provider with images
our $imagepath = "/var/lib/vdrmedia/epgdata";
our $imagetype = ".png";    		# enter the imagetype, that your skin supports
our $imagesize = "120x120"; 		# the desired size of the Image

# settings for TVMovie
our $baseurl = "http://tvmovie.kunde.serverflex.info/onlinedata/xml-gz5/";  
our $aendurl = "http://tvmovie.kunde.serverflex.info/onlinedata/xml-aend-gz5/";  
our $useupdate = 1;                     # use Updatefiles ? 1=true/0=false
our $marktvmupdate = "";		# Prefix for updated events. Leave
					# empty, if you dont want this.
our $tvmimgurl = "http://www.tvmovie.de/imageTransfer/XL";


# settings for TVInfo 
# Attention: these settings are obsolete since they prohibit the use of their EPG.
our $http_base = "http://www.tvinfo.de/";
our $loginURL = "exe.php3?";
our $listeURL = "target=senderlist.inc";
our $http_proxy = "";                   # example: http://172.16.1.1:3128/
our $tvicache_files = 1;                # 1=true/0=false

# settings for TVMerkzettelimport
our $username = "login";
our $password = "password";
our $tvinfoprefix = "(Timer von TVInfo)";
our $prio="99";
our $lifetime="99";
our $MarginStart = 10;
our $MarginStop = 10;
our $merkzettelURL = "target=merk.inc";
our $tviwantgenrefolder = 0;		# you want folders like Spielfilm~Drama ?
					# 1=true/0=false
our $tviwantseriesfolder = 0;		# you want folders for series
					# 1=true/0=false
# settings for hoerzu
# settings for hoerzu
our $hoerzuurl = "http://www.epgdata.com/index.php?action=sendPackage&dataType=xml&dayOffset=";
our $hoerzupin = "";

#settings for infosat
our $infosaturl="/var/lib/vdrmedia/epgdata/received_data";
