#!/usr/bin/perl -U

#####################################################
#  PPLOG 1.2b (PERL/jQuery powered blog) - a jQuery supported version of PPLOG 1.1b
#	 The idea of this blog, is a very simple yet powerful and beautiful blog. Enjoy.
#   Now fully supports UTF-8
#
#	 PPLOG 1.1b coded by Federico Ramírez (fedekun), fedekiller@gmail.com
#
#	 PPLOG uses the GNU Public Licence v3, http://www.opensource.org/licenses/gpl-3.0.html
#
#	 Powered by YAGNI (You Ain't Gonna Need It)
#	 YAGNI: Only add things, when you actually need them. Not because you think you will.
#
#####################################################
#
#  Notes specific to PPLOG 1.2a (jQuery version):
#
#  - You'll need to edit some more $config vars than normal, but most will work as they are.
#  - You can enable stylesheet switching, jQuery, code highlighting and lightboxes separately.
#  - The [box] bbcode tag produces lightboxes when enabled. It takes a filename, or full URL.
#
#  NOTE: [box]filename.jpg[/box] requires a 'filename.jpg' and a 'filename.jpg' thumbnail 
#  to be in the $config_imgFilesFolder and $config_imgThumbsFolder folders respectively.
#  (thumbnails must have the same filename as the full size image, to be found correctly)
#
#  For more info on the kind of URLs that [box] can take, you must read the link below:
#  http://www.no-margin-for-errors.com/projects/prettyphoto-jquery-lightbox-clone/
#
######################################################

#BK 8jul09 patch from fedekun, blog writes zero-byte file if leave title off a post.
#BK 8jul09 removed this from all submit forms, doesn't work with opera and ie...
# onclick="javascript:this.disabled=true"
# sc0ttman, march 2011, fixed some spelling errors, slight changes to formatting and text entries ("Edit Entry"-->"Save Entry", etc)
# sc0ttman, march 2011, added new "$config_" vars - for "server root", "js", "image" and "thumbnail" folders
# sc0ttman, march 2011, all stylesheets must be named "style*.css" (examples: style.css, style1.css, style2.css)
# sc0ttman, march 2011, added "Change styles" feature, uses cookies to keep chosen stylesheet, has menu item (above 'Main Menu')
# sc0ttman, march 2011, added jQuery plus option to enable/disable it
# sc0ttman, march 2011, added jQuery code highlighting, plus option to enable/disable
# sc0ttman, march 2011, added jQuery lightboxes, plus option to enable/disable
# sc0ttman, march 2011, added [box] bbcode tag, with button, enabled with lightboxes
# sc0ttman, march 2011, added a "thumbs" folder, used by [box] - keep the small versions of your full-size images here (use same filenames!) 
# sc0ttman, march 2011, [img] and [box] bbcode tags to take either a full URL, or the filename (no path required) of an image in "$config_imgFilesFolder"
# sc0ttman, march 2001, all additional javascripts and related HTML disabled when relevant features not enabled - never include JS code, that is not in use
#110712: fixed getStyles function, fixed 32 days in month; fixed UTF-8 encoding inc RSS; updated PPLOG references to SJPPLOG; 
#200213, added upload page for admin user only: upload imgs, thumbs and css files.. no error checking .. 
#020313 added anchor tags to all comments .. updated style1.css, added anchor id..
#030313 added options to load all jquery related JS and CSS from content delivery networks
#2005013 fixed single quote comment errors, fixed ordering of archive posts, added multiple categories for each post, updated newEntry layout, 
#210613 fixes in single quotes, fixes for unquoting stuff (for nicedit?), added [style] and [center] bcode, fixed order of archive entries, 
#020713  moved config and funcs to external files.. added $config_currentStylesheet.. added admin page to edit config file & stylesheet.. fallback to default css file & print error, if needed.. added 'class' to bbcode.. 
#030713 add warning if errors in config file
#160316 Add multiple 'users' for multiuser blog. Improve workflow. Lock down admin password.

use CGI::Carp qw/fatalsToBrowser/;	# This is optional
use CGI':all';
use POSIX qw(ceil floor);
use POSIX qw/strftime/; #020313
use File::Copy;
#use strict;							# This is also optional #020713

#020713 put settings & funcs in external file
do "pup_pplog.conf.pl" or (require "pup_pplog.conf.pl.bak");
#require "pup_pplog.conf.pl"; 
require "pup_pplog.func.pl";

if(r('do') eq 'RSS')
{
	my @baseUrl = split(/\?/, 'http://'.$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'});
	my $base = $baseUrl[0];
	my @entries = getFiles($config_postsDatabaseFolder);
	my $limit;
	
	#110712 UTF-8 RSS fix
	print header(-charset => qw(utf-8)), '<?xml version="1.0" encoding="UTF-8"?>
	<rss version="2.0">
	<channel>
	<title>'.$config_blogTitle.'</title>
	<description>'.$config_metaDescription.'</description>
	<link>http://'.$ENV{'HTTP_HOST'}.substr($ENV{'REQUEST_URI'},0,length($ENV{'REQUEST_URI'})-7).'</link>';
	
	if($config_entriesOnRSS == 0)
	{
		$limit = scalar(@entries);
	}
	else
	{
		$limit = $config_entriesOnRSS;
	}
	
	for(my $i = 0; $i < $limit; $i++)
	{
		my @finalEntries = split(/"/, $entries[$i]);
		my $content = $finalEntries[1];
		$content =~ s/\</&lt;/gi;
		$content =~ s/\>/&gt;/gi;
		print '<item>
		<link>'.$base.'?viewDetailed='.$finalEntries[4].'</link>
		<title>'.$finalEntries[0].'</title>
		<category>'.$finalEntries[3].'</category>
		<description>'.$content.'</description>
		</item>';
	}
	
	print '</channel>
	</rss>';
}
else  #html output
{
# sc0ttman BOF
my $jqueryCodeHighlight_init;
if($config_enableJQueryCodeHighlighting == 1){
	if ( $config_enableJQueryCodeHighlightingCDN == 1 ) { #030313
		$jqueryCodeHighlight_init = '<script type="text/javascript" src="http://balupton.github.com/jquery-syntaxhighlighter/scripts/jquery.syntaxhighlighter.min.js"></script>'
	} else {
		$jqueryCodeHighlight_init = '<script type="text/javascript" src="'.$config_JSFilesFolder.'/jquery.syntaxhighlighter.min.js"></script>'	
	}
$jqueryCodeHighlight_init .= '<script type="text/javascript">
$.SyntaxHighlighter.init({
	//\'BaseUrl\': \''.$config_JSFilesFolder.'/\', // uncomment this to use local files (path may need editing)   // http://balupton.github.com/jquery-syntaxhighlighter/scripts/jquery.syntaxhighlighter.min.js
	//\'prettifyBaseUrl\': \''.$config_JSFilesFolder.'/prettify/\', // uncomment this to use local files (path may need editing)  // http://balupton.github.com/jquery-syntaxhighlighter/prettify/prettify.min.js
	\'debug\' : false,
	\'lineNumbers\' : false,
	\'alternateLines\' : false,
	\'stripEmptyStartFinishLines\': true,
	\'stripInitialWhitespace\': true,
	\'wrapLines\' : true,
	\'theme\': \'balupton\',
	\'themes\': [\'balupton\']
});
</script>
';
} else {
	$jqueryCodeHighlight_init = '';
}
my $jqueryLightbox_init;
if($config_enableJQueryLightboxes == 1){
	if ( $config_enableJQueryLightboxesCDN == 1 ) { #030313
		$jqueryLightbox_init = '<script src="http://aslamise.googlecode.com/files/prettyPhoto.js" type="text/javascript" charset="utf-8"/></script>
<link href="http://cdn.jsdelivr.net/prettyphoto/3.1.5/css/prettyPhoto.css" media="screen" rel="stylesheet" type="text/css" charset="utf-8"/>'
	} else { 
		$jqueryLightbox_init = '<link rel="stylesheet" href="'.$config_JSFilesFolder.'/prettyPhoto.css" type="text/css" media="screen" title="stylePrettyPhoto" charset="utf-8" />
<script type="text/javascript" src="'.$config_JSFilesFolder.'/jquery.prettyPhoto.js" charset="utf-8"></script>'
	}
	$jqueryLightbox_init .= '<script type="text/javascript" charset="utf-8">
$(document).ready(function(){
	$("a[rel^=\'prettyPhoto\']").prettyPhoto({
		showTitle: true,  // show title of lightbox, taken from href that loads it 
		animation_speed: \'fast\',  // either fast, normal or slow 
		opacity: .90,  // values 1 = no transparency, 0.5 = half transparent  
		allow_resize: true,  // resize images if larger than the lightbox window 
		theme: \'light_rounded\', // the theme to use, stored in /images/ptettyPhoto 
		hideflash: true, // hide flash when lightbox appears, if true 
		modal: false // allow ESCAPE key to exit, if false 
	});
});
</script>
';
} else {
	$jqueryLightbox_init = '';
}
# set jQuery
my $jquery_init;
if($config_enableJQuery == 1){
	if ( $config_enableJQueryCDN == 1 ){ #030313 jquery CDN
		$jquery_init = '<script type="text/javascript" src="http://code.jquery.com/jquery-1.4.4.min.js"></script>';
	} else {
		$jquery_init = '<script type="text/javascript" src="'.$config_JSFilesFolder.'/jquery.min.js"></script>';
	}
} else { # no jQuery at all
	$config_enableJQueryCodeHighlighting = 0;
	$config_enableJQueryLightboxes = 0;
	$jquery_init = '';
	$jqueryCodeHighlight_init = '';
	$jqueryLightbox_init = '';
}
# set changeStyle JS includes
my $changeStyle_init;
my $changeStyle_init_onload;
if ($config_enableStyleSelect == 1 ){
	$changeStyle_init = '<script type="text/javascript" src="'.$config_JSFilesFolder.'/changestyle.js"></script>';
	$changeStyle_init_onload = ' onload="set_style_from_cookie()"';
} else {
	$changeStyle_init = '';
	$changeStyle_init_onload = '';
}
# sc0ttman EOF
#110712 UTF-8 fix
print header(-charset => qw(utf-8)), '<!DOCTYPE HTML PUBLIC -//W3C//DTD HTML 4.01 Transitional//EN
http://www.w3.org/TR/html4/loose.dtd>
<html>
<head>
<link rel="icon" 
      type="image/png" 
      href="'.$config_currentFavicon.'">
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<meta name="Name" content="'.$config_blogTitle.'" />
<meta name="Revisit-After" content="'.$config_metaRevisitAfter.'" />
<meta name="Keywords" content="'.$config_metaKeywords.'" />
<meta name="Description" content="'.$config_metaDescription.'" />
<title>'.$config_blogTitle.' - Powered by SJPPLOG_NG</title>
'.$jquery_init.'
'.$jqueryCodeHighlight_init.$jqueryLightbox_init.'
<script language="javascript" type="text/javascript">
function surroundText(text1, text2, textarea){
	if (typeof(textarea.caretPos) !== "undefined" && textarea.createTextRange){
		var caretPos = textarea.caretPos, temp_length = caretPos.text.length;
		caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) === \' \' ? text1 + caretPos.text + text2 + \' \' : text1 + caretPos.text + text2;
		if (temp_length === 0){
			caretPos.moveStart("character", -text2.length);
			caretPos.moveEnd("character", -text2.length);
			caretPos.select();
		} else {
			textarea.focus(caretPos);
		}
	} else if (typeof(textarea.selectionStart) !== "undefined") {
		var begin = textarea.value.substr(0, textarea.selectionStart);
		var selection = textarea.value.substr(textarea.selectionStart, textarea.selectionEnd - textarea.selectionStart);
		var end = textarea.value.substr(textarea.selectionEnd);
		var newCursorPos = textarea.selectionStart;
		var scrollPos = textarea.scrollTop;
		textarea.value = begin + text1 + selection + text2 + end;
		if (textarea.setSelectionRange){
			if (selection.length === 0){
				textarea.setSelectionRange(newCursorPos + text1.length, newCursorPos + text1.length);
			} else {
				textarea.setSelectionRange(newCursorPos, newCursorPos + text1.length + selection.length + text2.length);
			}
			textarea.focus();
		}
		textarea.scrollTop = scrollPos;
	} else {
		textarea.value += text1 + text2;
		textarea.focus(textarea.value.length - 1);
	}
}
</script>
'.$changeStyle_init;
if($config_googlePlusAllowed == 1)
{
	print '<script src="https://apis.google.com/js/platform.js" async defer></script>'

}
my $missingStyle  = fixMissingStyles(); #020713 fix missing stylesheets
print '<link id=mainStyle href='.$config_currentStyleFolder.'/'.$config_currentStylesheet.' rel=stylesheet type=text/css media="Screen, print">  <!-- #020713 -->
<link href='.$config_currentStyleFolder.'/mobile.css rel=stylesheet type=text/css media="only screen and (max-width: 550px), only screen and (max-device-width: 480px)"> <!-- #040713 -->
<meta name="Viewport" content="width=device-width, initial-scale=1.0"/></head>
<body'.$changeStyle_init_onload.'><div id="header"><div id="subbox">'.$config_blogTitle.'</div></div>';

#if facebook
if($config_facebookAllowed == 1)
{
	print '<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.5";
  fjs.parentNode.insertBefore(js, fjs);
}(document, "script", "facebook-jssdk"));</script>';
}
if ( $missingStyle == 1 )
{
	print "<div class=error><center>Error: Stylesheet '<b>$missing_stylesheet</b>' not found, using default. Change <b>\$config_currentStylesheet</b> in your config file!</center></div>";
}
do "pup_pplog.conf.pl" or print "<div class=error><center>Error: Your config has errors in it, please update it!</center></div>"; #030713
print '<div id=all><div id=menu><div class="hide">'; #070413
# sc0ttman BOF - changeStyle menu item
if($config_enableStyleSelect == 1){
	my @styles = getStyles(); # get stylesheets
	if(scalar(@styles) > 0)
	{
		print '<h1>Change Stylesheet</h1>';
		foreach(@styles)
		{
			print '<a href="JavaScript:changeStyle(\''.$config_currentStyleFolder.'/'.$_.'\')">'.$_.'</a>';
		}
	}
}# sc0ttman EOF #040713
print '</div><h1><a href="">Main Menu</a></h1>
<div class="show"><a href=?page=1>Home</a>
<a href=?do=newEntry>New Entry</a>
<a href=?do=archive>Archive</a>
<a href="?do=RSS">RSS Feeds</a>';
if ($config_commentsRequireRegistration == 1)
{
	print '<a href=?do=reg title="You must register to post comments">Register</a>'
}
print '<a href=?do=admin>Admin</a> <!-- #020713 -->
<div class="hide">
<h1>Categories</h1>';			# Show Categories on Menu	THIS IS THE MENU SECTION
my @categories = sort(getCategories());
foreach(@categories)
{
	print '<a href="?viewCat='.$_.'">'.$_.'</a>';
}
print 'No categories yet.' if scalar(@categories) == 0;
#get a list of authors to show in popup
open(FILE, "<$config_postsDatabaseFolder/users.$config_dbFilesExtension.dat");
my $data = '';
my @listAuthors = '';
while(<FILE>)
{
	$data.=$_;
}
close(FILE);

if($triedAsAdmin == 0)
{
	my @users = split(/"/, $data);
	foreach(@users)
	{
		my @data = split(/'/, $_);
		my $auth = $data[0].', ';
		push(@listAuthors,$auth);
	}
}
$strAuthors =  "@listAuthors";
#110712 , UTF-8 fix
print '</div><div class="show">
<h1>Search</h1>
<form accept-charset="UTF-8" name="form1" method="post">
<input type="text" name="keyword">
<input type="hidden" name="do" value="search">
<input type="submit" name="Submit" value="Search"><br />
Title <input name="by" type="radio" value="0" checked> Content <input name="by" type="radio" value="1"> Author <input name="by" type="radio" value="5" title="Authors:'.$strAuthors.'">
</form>
</div><div class="hide">
<h1>Latest Entries</h1>';

my @entriesOnMenu = getFiles($config_postsDatabaseFolder);
my $i = 0;
foreach(@entriesOnMenu)
{
	if($i <= $config_menuEntriesLimit)
	{
		my @entry = split(/"/, $_);
		my $title = $entry[0];
		my $fileName = $entry[4];
		my @pages = getPages();
		my $do = 1;
		foreach(@pages)
		{
			if($_ == $entry[4])
			{
				$do = 0;
				last;
			}
		}
		
		if($do == 1)
		{
			print '<a href="?viewDetailed='.$fileName.'">'.$title.'</a>';
		}
		
		$i++;
	}
}

# Display Pages
my @pages = getPages();

if(scalar(@pages) > 0)
{
	print '</div><div class="show"><h1>Pages</h1>';  #040713

	#040713
	foreach(@pages)
 	{
		my $fileName = $_;
		my $content;
		open(FILE, "<$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content.=$_;
		}
		close FILE;
		my @data = split(/"/, $content);
		my $title = $data[0];
		print '<a href="?viewDetailed='.$fileName.'">'.$title.'</a>';
 	}
	print '</div><div class="hide">';
}
if($config_socialAllowed == 1) 
{
	print '<h1>Share</h1>';
	if($config_redditAllowed == 1)
	{
		# Show the Reddit Button if allowed
		print '<a target="_blank" href="http://reddit.com/submit?url=http://'.$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'}.'">
		Reddit This <img border="0" src="'.$config_imgFilesFolder.'/reddit.gif" /></a>';
	}
	if($config_twitterAllowed == 1)
	{
		#if twitter
		print '<a href="https://twitter.com/share?&text=Check%20out%20this%20post!&hashtags=puppylinux,linux" class="twitter-share-button" target="_blank">Tweet <img border="0" src="'.$config_imgFilesFolder.'/twitter.gif" /></a>';
	}
	if($config_facebookAllowed == 1)
	{
		#if facebook
		print '<a href="#">Facebook <div class="fb-share-button" data-href="'.$config_facebookSite.'" data-layout="icon"></div></a>';
	}
	if($config_googlePlusAllowed == 1)
	{
		#if G+
		print '<a href="#">Share G+ <g:plusone size="small" annotation="none"></g:plusone></a>';
	}
}
if($config_menuShowLinks == 1)
{
	# Show Some Links Defined on the Configuration
	
	if(@config_menuLinks > 0)
	{
		print '<h1>'.$config_menuLinksHeader.'</h1>';
		foreach(@config_menuLinks)
		{
			my @link = split(/,/, $_);
			print '<a href="'.$link[0].'">'.$link[1].'</a>';
		}
	}
}

if($config_showLatestComments == 1)
{
	# Latest comments on the menu
		
	my @comments = getComments();
	
	if(scalar(@comments) > 0)
	{
		print '<h1>Latest Comments</h1>';
	}
	
	my $i = 0;
	
	foreach(@comments)
	{
		if($i <= $config_showLatestCommentsLimit)
		{
			my @entry = split(/"/, $_);
			print '<a href="?viewDetailed='.$entry[4].'#'.$entry[5].'" title="Posted by '.$entry[1].'">'.$entry[0].'</a>'; #020313
			$i++;
		}
	}
	print '<a href="?do=listComments">List All Comments</a>' if scalar(@comments) > 0;
}

if($config_allowCustomHTML == 1)
{
	# Display Custom HTML Defined on the configuration
	
	print $config_customHTML;
}

if(($config_showUsersOnline == 1) || ($config_showHits == 1))
{
	print '<h1>Stats</h1>';
}

if($config_showUsersOnline == 1)
{
	# Show users online
	
	my $remote = $ENV{"REMOTE_ADDR"};
	my $timestamp = time();
	my $timeout = ($timestamp-$config_usersOnlineTimeout);
	
	if((-s "$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo") > (1024 * $config_dbSize))		# If its bigger than 1024 * dbSize MB, truncate the file and start again
	{
		open(FILE, "+>$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	}
	else
	{
		open(FILE, ">>$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	}
	
	print FILE $remote."||".$timestamp."\n";
	close FILE;
	my @online_array = ();
	my $content;
	open(FILE, "<$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	while(<FILE>)
	{
		$content.=$_;
	}
	close FILE;
	
	my @l = split(/\n/, $content);
	foreach(@l)
	{
		my @f = split(/\|\|/, $_);
		my $ip = $f[0];
		my $time = $f[1];
		if($time >= $timeout)
		{
			push(@online_array, $ip);
		}
	}
	@online_array = array_unique(@online_array);
	print '<a id=x>Users Online: '.scalar(@online_array).'</a>';
}

if($config_showHits == 1)
{
	# Display Hits
	
	# Check hits
	my $hits = `wc -l < "$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo"`;
	print '<a id=x>Hits: <b>'.$hits.'</b> <small> (since '.$config_blogStart.')</small></a>';
}
if($config_showMap == 1)
{
	print '<h1>World Audience</h1>
	<img class="map" src="cgi-bin/map.pl" alt="map" />';
}

print '</div></div></div><div id=content>';  #040713

foreach(@config_ipBan)
{
	if($ENV{'REMOTE_ADDR'} == $_)
	{
		dienice($config_bannedMessage);
	}
}

# Start with GETS and POSTS		CONTENT SECTION

if(r('do') eq 'newEntry')
{
	# Add Secure (This page will appear before the add one)
	
	#110712 , UTF-8 fix
	print '<h1>Adding Entry...</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>User</td>
	<td><input name="bloguser" type="text" id="bloguser"></td>
	</tr>
	<tr>
	<td>Pass</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="doNewEntry"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Add New Entry"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('do') eq 'addMember')
{
	# Add Secure (This page will appear before the add one)
	
	#110712 , UTF-8 fix
	print '<h1>Add Member</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>Admin Password</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="doAddMember"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Add New Member"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('process') eq 'uploadfiles') #200213
{

		print '<h1>Upload File(s)</h1>';

		# Load the contents of the form into the $IMGFORM variable.
		my $IMGFORM = new CGI;
		my $THUMBFORM = new CGI;
		my $CSSFORM = new CGI;
		#set vars to be used
		my $StoreImgDirectory = '../www/blog/images/';
		my $StoreThumbDirectory = '../www/blog/thumbs/';
		my $StoreCSSDirectory = '../www/blog/css/';
		my $StoreImgName = '';  #leave blank to keep same file name
		my $StoreThumbName = ''; #leave blank to keep same file name
		my $StoreCSSName = ''; #leave blank to keep same file name
		my $ThankYouPage = ''; #leave blank to return to same page

		sub StoreUploadedImg
		{
			# Grab the filehandle of the uploaded file.
			my $filehandle = $IMGFORM->upload('filename');
			# Return false if no file uploaded.
			return '' unless $filehandle;
			# Grab the file name of the uploaded file.
			my $filename = $IMGFORM->param('filename');
			# Strip any path information from the file name.
			$filename =~ s!^.*[/\\]!!;
			# Determine file storage name and directory location.
			$StoreImgName = $filename unless $StoreImgName =~ /\w/;
			$StoreImgDirectory .= '/' if $StoreImgDirectory =~ /\w/ and $StoreImgDirectory !~ m![\\/]$!;
			$StoreImgDirectory = "$ENV{DOCUMENT_ROOT}$StoreImgDirectory" if $StoreImgDirectory =~ m!^[\\/]!;
			# Store the file.
			my $buffer;
			open UPLOADED,">$StoreImgDirectory$StoreImgName";
			binmode UPLOADED; # for Win/DOS operating systems
			while(read $filehandle,$buffer,1024) { print UPLOADED $buffer; }
			close UPLOADED;
			# Return true.
			return 1;
		} # sub StoreUploadedImg

		sub StoreUploadedThumb
		{
			# Grab the filehandle of the uploaded file.
			my $thumbhandle = $THUMBFORM->upload('thumbname');
			# Return false if no file uploaded.
			return '' unless $thumbhandle;
			# Grab the file name of the uploaded file.
			my $thumbname = $THUMBFORM->param('thumbname');
			# Strip any path information from the file name.
			$thumbname =~ s!^.*[/\\]!!;
			# Determine file storage name and directory location.
			$StoreThumbName = $thumbname unless $StoreThumbName =~ /\w/;
			$StoreThumbDirectory .= '/' if $StoreThumbDirectory =~ /\w/ and $StoreThumbDirectory !~ m![\\/]$!;
			$StoreThumbDirectory = "$ENV{DOCUMENT_ROOT}$StoreThumbDirectory" if $StoreThumbDirectory =~ m!^[\\/]!;
			# Store the file.
			my $buffer;
			open UPLOADED,">$StoreThumbDirectory$StoreThumbName";
			binmode UPLOADED; # for Win/DOS operating systems
			while(read $thumbhandle,$buffer,1024) { print UPLOADED $buffer; }
			close UPLOADED;
			# Return true.
			return 1;
		} # sub StoreUploadedThumb

		 print <<IMGFORM;
			<form accept-charset="UTF-8" enctype="multipart/form-data" name="form1" method="post">
			<table>
			<tr>
			<td>Upload an image to <b>$config_imgFilesFolder</b>: </td>
			</tr>
			<tr>
			<td>If the image is to be used in a post with [img] tag then it must be no wider than 500px, 
			however if it to be used with [box] tag it can be any size, but bear in mind loading times.</td>
			</tr>
			<tr>
			<td>
			<input type="file" name="filename" size="55">
			<input name="process" type="hidden" id="process" value="uploadfiles">
			<input name="pass" type="hidden" id="pass" value="$pass">
			</td>
			<td>&nbsp;</td>
			<td><input type="submit" name="Submit" value="Upload"></td>
			</tr>
			</table>
			</form>
IMGFORM
			
		 print <<THUMBFORM;
			<form accept-charset="UTF-8" enctype="multipart/form-data" name="form2" method="post">
			<table>
			<tr>
			<td>Upload a smaller thumbnail image to <b>$config_imgThumbsFolder</b>: </td>
			<tr>
			<td>A thumb can only be used with the [box] tag. It must have a corresponding full size 
			image uploaded to <i>images</i> directory. The thumbnail image should be less than 400px wide
			and have the identical name to the main image.</td>
			</tr>
			</tr>
			<tr>
			<td>
			<input type="file" name="thumbname" size="55">
			<input name="process" type="hidden" id="process" value="uploadfiles">
			<input name="pass" type="hidden" id="pass" value="$pass">
			</td>
			<td>&nbsp;</td>
			<td><input type="submit" name="Submit" value="Upload"></td>
			</tr>
			</table>
			</form>
THUMBFORM
	
		my $storedImg = StoreUploadedImg;
		my $storedThumb = StoreUploadedThumb;
}
elsif(r('do') eq 'admin') #0207013
{

	print '<h1>Login to Admin Page..</h1>';
	if(! -s $config_adminPassFile)
	{
		print '<p>Please create an Administrator Password on the next page by selecting &quot;Set/Reset Administrator Password&quot;.</p>';
	}
	print '<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>Pass</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="editConfigFiles"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Continue"></td>
	</tr>
	</table>
	</form>';

}
elsif(r('do') eq 'reg') #210316
{
	print '<h1>Registration</h1>
	<p>Please fill out this form with your details for the administrator
	of <b>'.$config_blogTitle.'</b> to consider your registration for the <u>comments</u> section.</p>
	<p>This is a security measure against spam and other undesirable posts.</p>
	<p>Please allow up to three days for your registration to be processed.</p>
	<p>Passwords can be changed once you are granted access.</p>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>Desired Username</td>
	<td><input name="user" type="text" id="user"></td>
	</tr>
	<tr>
	<td>User Password</td>
	<td><input name="pass" type="password" id="pass"></td>
	</tr>
	<tr>
	<td>Email Address</td>
	<td><textarea name="email" style="height: 20px;width: 300px;" type="text"
	id="email"></textarea></td>
	</tr>
	<tr>
	<td>Optional Comment</td>
	<td><textarea name="content" cols='.$config_textAreaCols.'" rows="'.$config_textAreaRows.'"
	style="height: 150px; width: 400px;" id="content"></textarea></td></tr>
	<td><input name="process" type="hidden" id="process" value="sendMail"></td>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Register"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('process') eq 'sendMail')
{
	my $user = r('user');
	my $pass = r('pass');
	my $email = r('email');
	my $content = r('content');
	if($user eq '' || $pass eq '' || $email eq '')
	{
		dienice("All fields are neccesary!");
	}
	if (grep {/.+\@.+\..+/} $email)
	{
		print "Sending message.";
		my $content = "Hello, I am sending this mail because $user has requested to post at $config_blogTitle: http://".$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'}."\nUser: $user\nPassword: $pass\nEmail: $email\nComment: $content\n";
		open (MAIL,"|/usr/sbin/sendmail -t");
		print MAIL "To: $config_sendMailWithNewCommentMail\n";
		print MAIL "From: SJPPLOG_NG \n";
		print MAIL "Subject: New Registration on your SJPPLOG_NG Blog\n\n";
		print MAIL $content;
		close(MAIL);
		print "Your message has been sent.";
	}
	else
	{
		dienice("Please enter a valid email address.");
	}
	
}
elsif(r('process') eq 'editConfigFiles') #020713
{
	my $pass = r('pass');
	my $auth = 0;
	if(-s $config_adminPassFile)
	{
		
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
		else
		{
			$auth = 1;
		}
	}
	else
	{
		if($pass ne $config_adminPass)
		{
			dienice("Passwords do not match!");
		}
		else
		{
			print '<span style="color:red;">WARNING: For security you must set the Admin Password!"</span>';
			$auth = 1;
		}
	}
	my $editFolder = "$config_wwwEditFolder/$config_currentStyleFolder";
	if($auth == 1)
	{
		my $configFile = "pup_pplog.conf.pl";
		my $content = '';
		my $content2 = '';
		my $pass = r('pass');
		open (FILE, $configFile) or print 'Could not open Config file';
		while (<FILE>){$content .= $_;}
		close FILE;
		open (FILE, "$editFolder/$config_currentStylesheet") or print 'Could not open stylesheet file';
		while (<FILE>){$content2 .= $_;}
		close FILE;
		print '<h1>Change the settings of the blog</h1>
	   Warning! This might break the blog, be very careful!&nbsp;&nbsp;<a href="?page=1">Get me out of here!</a>
	   <h3>Admin Tasks:</h3>
	   <a href=?do=addMember>New Member</a><br>
	   <a href=?do=changeAdminPass>Set/Reset Administrator Password</a>
	   <h3>Config File:</h3>
	   <form accept-charset="UTF-8" name="submitform" method="post">
	   <textarea name="content"  rows="30" cols="80" wrap="off" style="font-size:1.1em;color;black;max-width:100%" id="content">'
	   .$content.
	  '</textarea><br /><br />
	   <h3>Stylesheet ('.$config_currentStylesheet.'):</h3>
	   <textarea name="content2"  rows="30" cols="80" wrap="off" style="font-size:1.1em;color;black;max-width:100%" id="content2">'
	   .$content2.
	  '</textarea><br /><br />
	   <input name="pass" type="hidden" id="pass" value="'.$pass.'">
	   <input name="process" type="hidden" id="process" value="saveConfig">
	   <input type="submit" name="Submit" type="hidden" value="Save Changes"></form>';
	}
	else
	{
		print "Wrong password."
	}
}
elsif(r('do') eq 'changeAdminPass')
{
	if(-s $config_adminPassFile)
	{
		print'<h1>Change Administrator Password</h1>
		<form accept-charset="UTF-8" name="form0" method="post">
		<table>
		<td>Old Pass</td>
		<td><input name="oldpass" type="password" id="oldpass">
		</tr>
		<tr>
		<td>New Pass</td>
		<td><input name="newpass" type="password" id="newpass">
		<input name="process" type="hidden" id="process" value="editPass"></td>
		</tr>
		<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="Submit" value="Edit Password"></td>
		</tr>
		</table>
		</form>';
	}
	else
	{
		print'<h1>Create Administrator Password</h1>
		<form accept-charset="UTF-8" name="form0" method="post">
		<table>
		<td>New Pass</td>
		<td><input name="newpass" type="password" id="newpass">
		<input name="process" type="hidden" id="process" value="editPass"></td>
		</tr>
		<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="Submit" value="Create Password"></td>
		</tr>
		</table>
		</form>';
	}
}
elsif(r(process) eq 'editPass')
{
	my $oldpass = r('oldpass');
	my $newpass = r('newpass');
	if (-s $config_adminPassFile)
	{
		# authenticate oldpass
		open(FILE, "<$config_adminPassFile");
		my $currPass = '';
		while(<FILE>)
		{
			$currPass.=$_;
		}
		close(FILE);
		if(crypt($oldpass, $config_randomString) ne $currPass)
		{
			print '<p>Wrong password.</p>';
		}
		else
		{
			# update admin password
			open(FILE, ">$config_adminPassFile");
			print FILE crypt($newpass, $config_randomString);
			close FILE;
			print '<p>Administrator Password updated.</p>';
		}
	}
	else
	{
		# create admin password
		unless(open(FILE, ">$config_adminPassFile"))
		{
			dienice("Unble to create $config_adminPassFile");
		}
		print FILE crypt($newpass, $config_randomString);
		close FILE;
		print '<p>Administrator Password created.</p>';
	}
}
elsif(r('process') eq 'saveConfig')
{
	my $pass = r('pass');
	my $adminPass = '';
	if(-s $config_adminPassFile)
	{
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
	}
	my $editFolder = "$config_wwwEditFolder/$config_currentStyleFolder";
	if (r('content') ne '' && r('content2') ne '')
	{
		my $content = basic_r('content');
		my $content2 = basic_r('content2');
		my $configFile = "pup_pplog.conf.pl";
		unless (rename ("$configFile", "$configFile.bak"))
		{
			dienice("Could not back up Config file, changes not saved.");
			
		}
		unless (rename ("$editFolder/$config_currentStylesheet", "$editFolder/$config_currentStylesheet.bak"))
		{
			dienice("Could not back up Stylesheet file, changes not saved.");
			
		}
		open (FILE, ">$configFile");
		print FILE $content and print '<br />Your config options have been changed.';
		close FILE;
		open (FILE, ">$editFolder/$config_currentStylesheet");
		print FILE $content2 and print '<br />Your stylesheet has been updated.';
		close FILE;
		print '<br /><br /><a href="?page=1">Return to homepage</a>';
	}
	else
	{
		 print '<br />Something went wrong, changes not saved <a href="?do=editConfig">try again?</a>';
	}
}
elsif(r('process') eq 'doNewEntry')
{
	# Blog Add New Entry Form
	
	my $pass = r('pass');
	my $bloguser = r('bloguser');
	#my $triedAsAdmin = 0;
	my $do = 0;
	my $isUser = 0;
	# Start of author checking, for identity security
	if (-f "$config_postsDatabaseFolder/users.$config_dbFilesExtension.dat")
	{
		open(FILE, "<$config_postsDatabaseFolder/users.$config_dbFilesExtension.dat") or dienice("Could not open file.");
		my $data = '';
		while(<FILE>)
		{
			$data.=$_;
		}
		close(FILE);
		
		#if($triedAsAdmin == 0)
		#{
		my @users = split(/"/, $data);
		foreach(@users)
		{
			my @data = split(/'/, $_);
			if($bloguser eq $data[0])
			{
				$isUser = 1;
				if(crypt($pass, $config_randomString) eq $data[1])
				{
					$do = 1;
				}
				last;
			}
		}
	}
	else
	{
		dienice("No posters exist! Please create one.");
	}
	# End of author checking, start adding comment
	if($do == 1)
	{
		my @categories = getCategories();
		#110712 UTF-8 fix
		print '<h1>Making new entry...</h1>	';
		print '<p><a href=?do=changePass>Change Password</a></p>';
		if ( $config_enableUploadPage == 1 ){
			print '<p><a href=?process=uploadfiles target=_blank title="These are uploaded directly to the server">Upload Images</a></p>';
		}
		print '<p><a href=?do=issues target=_blank>Known issues and work-arounds</a></p>';
		print '<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table>
		<tr>
		<td style="width: 100px;">Title</td>
		<td><input name=title type=text id=title></td>
		</tr>';
		if($config_useHtmlOnEntries == 0)
		{
			print '<tr>
			<td>&nbsp;</td>
			<td><input type="button" style="width:35px;font-weight:bold;" onClick="surroundText(\'[b]\', \'[/b]\', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="width:35px;font-style:italic;" onClick="surroundText(\'[i]\', \'[/i]\', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="width:35px;text-decoration:underline;" onClick="surroundText(\'[u]\', \'[/u]\', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="width:35px" onClick="surroundText(\'[center]\', \'[/center]\', document.forms.submitform.content); return false;" value="<->" />
			<input type="button" style="width:35px" onClick="surroundText(\'[class=CLASS]\', \'[/class]\', document.forms.submitform.content); return false;" value="class" />
			<input type="button" style="width:35px" onClick="surroundText(\'[style=text-size:;color:]\', \'[/style]\', document.forms.submitform.content); return false;" value="style" />
			<input type="button" style="width:35px" onClick="surroundText(\'[url]\', \'[/url]\', document.forms.submitform.content); return false;" value="url" />
			<input type="button" style="width:35px" onClick="surroundText(\'[img]\', \'[/img]\', document.forms.submitform.content); return false;" value="img" />
			<input type="button" style="width:35px" onClick="surroundText(\'[code]\', \'[/code]\', document.forms.submitform.content); return false;" value="code" />'; #210613 #020713 added class
			# sc0ttman
			if($config_enableJQueryLightboxes == 1) { print '
			<input type="button" style="width:35px;" onClick="surroundText(\'[box]\', \'[/box]\', document.forms.submitform.content); return false;" value="box" />'; }
			print '</td>
			</tr>';
			#sc0ttman
		}
		else
		{
			print '<script src="http://js.nicedit.com/nicEdit.js" type="text/javascript"></script><script type="text/javascript">bkLib.onDomLoaded(nicEditors.allTextAreas);</script>' if($config_useWYSIWYG == 1);
		}
		print '<tr><td>Content<br />(You can use BBCODE)<br /><a href="?do=showSmilies" target="_blank">Show Smilies</a></td>
		<td><textarea name="content" cols='.$config_textAreaCols.'" rows="'.$config_textAreaRows.'" ';
		print ' style="height: 400px; width: 400px;" ' if( ($config_useWYSIWYG == 1) && ($config_useHtmlOnEntries == 1) );
		#200513 updated layout, added help info on adding multiple cats
		print ' id="content"></textarea></td></tr><tr><td>Category</td><td><input name="category" type="text" id="category"> &nbsp;&nbsp;(Available: <i>';
		my $i = 1;
		foreach(@categories)
		{
			if($i < scalar(@categories))	# Here we display a comma between categories so is easier to undesrtand
			{
				print $_.', ';
			}
			else
			{
				print $_;
			}
			$i++;
		}
		print '</i> ) <a href="javascript:alert(\'Add the category name. You can separate multiple categories by a single quote [\\\'] \')">(?)</a></td></tr>';
		if($config_showPageCheckbox == 1)	
		{	
			print '<tr>
			<td>Is a Page <a href="javascript:alert(\'A page is basically a post which is linked in the menu and not displayed normally\')">(?)</a></td>
			<td><input type="checkbox" name="isPage" value="1"></td>
			</tr>';
		}
		print '<tr>
		<td>User</td>
		<td><input name="bloguser" type="text" id="bloguser" value='.$bloguser.'>
		</tr>
		<tr>
		<td><input name="process" type="hidden" id="process" value="newEntry"></td>
		</tr>
		<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="Submit" value="Add Entry"></td>
		</tr>
		</table>
		</form>';
	}
	else
	{
		if ($isUser == 0)
		{
			dienice("$bloguser, you are not registered to post here. Please Register.");
		}
		else
		{
			dienice("Wrong Password $bloguser!");
		}
	}
}
elsif(r('do') eq 'issues')
{
	print '<h1>Known Issues and Work-arounds</h1>
	<ul>
	<li><b>Bug with smilies</b> - when <i>editing</i> a post with smilies be sure to
	remove the smilie URL and add back in the colon|smile|colon syntax. <br>
	<i>eg:</i> <b>:cool:</b> (fixed!)</li>
	<li><b>Bug with [style] BB tag</b> - if using double quotes in styles these
	change to html entities baulking the actual post. You can use styles without quotes.</li>
	<li><b>Using [box] tag</b> - be sure to upload an image and a thumbnail with an
	identical name. Then just enclose the filename in the [box] tags.</li>
	<li><b>You can edit your post</b> - take heed of the above bugs and work-arounds.</li>
	<li><b>You can not delete your posts</b> - Drop me an email 
	<a href="mailto:'.$config_webMasterEmail.'?Subject=Delete%20Post" target="_top">here</a>
	and I will delete your post.</li>
	</ul>';
}
elsif (r('do') eq 'changePass')
{
	print '<h1>Change Password</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>User</td>
	<td><input name="user" type="text" id="user"></td>
	</tr>
	<tr>
	<td>New Pass</td>
	<td><input name="newpass" type="password" id="newpass">
	<input name="process" type="hidden" id="process" value="newPassword">
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Save New Password"></td>
	</tr>
	</table>
	</form>';
}
elsif (r('process') eq 'newPassword')
{
	my $user = r('user');
	my $newpass = r('newpass');
	print '<b>'.$user.'</b>: Your new password is <b>'.$newpass.'</b><br /><br />';
	my $encNewPass = crypt($newpass, $config_randomString);
	
	# check if user or commenter 210316
	my $dataFile = "$config_postsDatabaseFolder/users.$config_dbFilesExtension.dat";
	my $result = 2;
	open(AFILE, "<$dataFile") or dienice("Could not open file");
	while(<AFILE>)
	{
		my @blogUser = split(/"/, $_);
		foreach(@blogUser)
		{
			my @bUser = split(/'/, $_);
			if ($bUser[0] eq $user)
			{
				$result = 0;
				last;
			}
		}
	}
	close(AFILE);
	if ($result == 2)
	{
		dienice("No user of that name.");
	}
	# rewrite the users file
	open(FILE, "<$dataFile") or dienice("Could not open file.");
	close(FILE);
	my $encOldPass = '';
	my @users = split(/"/, $data);
	open(NFILE, ">>$dataFile.new") or dienice("Could not open file.");
	foreach(@users)
	{
		my @data = split(/'/, $_);
		if($user eq $data[0])
		{
			$encOldPass = $data[1];
			print NFILE $user."'".$encNewPass.'"';
		}
		else
		{
			print NFILE $data[0]."'".$data[1].'"';
		}
	}
	close (NFILE);
	move($dataFile.'.new', $dataFile) or dienice("The move operation failed.");
	print '<b>Password is updated!</b>';
}
elsif(r('process') eq 'doAddMember')
{
	my $pass = r('pass');
	if(-s $config_adminPassFile)
	{
		
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
	}
	else
	{
		if($pass ne $config_adminPass)
		{
			dienice("Passwords do not match!");
		}
	}
	
	print '<h1>Add Member</h1>
	<p>Choose the type of member and then fill out their desired Username
	and Password.</p>
	<form accept-charset="UTF-8" name="form1" method="post">
	Commenter <input name="type" type="radio" value="0" checked> Poster <input name="type" type="radio" value="1">
	<table>
	<td>Member name</td>
	<td><input name="bloguser" type="text" id="bloguser"></td>
	</tr>
	<tr>
	<td>Member Password</td>
	<td><input name="pass" type="password" id="pass"></td>
	<td><input name="process" type="hidden" id="process" value="saveMember"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Add New Member"></td>
	</tr>
	</table>
	</form>';

}
elsif(r('process') eq 'saveMember')
{
	my $bloguser = r('bloguser');
	my $pass = r('pass');
	my $type = r('type');
	my $baseFile = '';
	if($type == 0)
	{
		$baseFile = $config_commentsDatabaseFolder.'/users.'.$config_dbFilesExtension.'.dat';
	}
	else
	{
		# first add them to commenters
		open(CFILE, ">>$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat") or dienice("Could not open file.");
		print CFILE $bloguser."'".crypt($pass, $config_randomString).'"';
		close CFILE;
		
		$baseFile = $config_postsDatabaseFolder.'/users.'.$config_dbFilesExtension.'.dat';
	}
	open(FILE, ">>$baseFile") or dienice("Could not open file.");
	print FILE $bloguser."'".crypt($pass, $config_randomString).'"';
	close FILE;
	print 'Member '.$bloguser.' has been created.<br>';
	
}
elsif(r('process') eq 'newEntry')
{
	# Blog Add New Entry Page
	
	#my $pass = r('pass');
	my $bloguser = r('bloguser');
	
	#BK 7JUL09 patch from fedekun, fix post with no title that caused zero-byte message...	
	my $title = r('title');
	my $content = '';
	if($config_useHtmlOnEntries == 0)
	{
		$content = bbcode(r('content'));
	}
	else
	{
		$content = basic_r('content');
	}
	my $category = r('category');
	my $isPage = r('isPage');
   
	if($title eq '' || $content eq '' || $category eq '')
	{
		dienice("All fields are neccesary!");
	}

	
	my @files = getFiles($config_postsDatabaseFolder);
	my @lastOne = split(/"/, $files[0]);
	my $i = 0;
	
	if($lastOne[4] eq '')
	{
	$i = sprintf("%05d",0);
	}
	else
	{
	$i = sprintf("%05d",$lastOne[4]+1);
	}
	
	unless(-d "$config_postsDatabaseFolder")
	{
	print 'The folder '.$config_postsDatabaseFolder.' does not exists...Creating it...<br />';
	mkdir($config_postsDatabaseFolder, 0755);
	}
	
	open(FILE, ">$config_postsDatabaseFolder/$i.$config_dbFilesExtension");
	
	my $date = getdate($config_gmt);
	$content =~ s/'/&apos;/g; $content =~ s/"/&quot;/g; # jamesbond 20130323 #210613
	$title =~ s/'/&apos;/g; $title =~ s/"/&quot;/g; # jamesbond 20130323 #210613
	print FILE $title.'"'.$content.'"'.$date.'"'.$category.'"'.$i.'"'.$bloguser;    # 0: Title, 1: Content, 2: Date, 3: Category, 4: FileName, 5: Author
	print 'Your post '.$title.' has been saved. <a href="?page=1">Go to Index</a>';
	close FILE;
	
	if($isPage == 1)
	{
	open(FILE, ">>$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
	print FILE $i.'-';
	close FILE;
	}
        
	#BK 7JUL09 patch end.
}
elsif(r('viewCat') ne '')
{
	# Blog Category Display
	
	my $cat = r('viewCat');
	my @entries = getFiles($config_postsDatabaseFolder);
	my @thisCategoryEntries = ();
	#200513 multiple cats
	foreach my $item(@entries)
	{
		#200513 multiple cats
		my @split = split(/"/, $item);								# [0] = Title	[1] = Content	[2] = Date	[3] = Category
		my @nextsplit = split(/'/,$split[3]);							# Efia change to accomodate more than one category
		if (grep { $_ eq $cat } @nextsplit)
		{
			#200513 multiple cats
			push(@thisCategoryEntries, $item);
		}
	}
	
	# Pagination - This is the so called Pagination
	my $page = r('p');																# The current page
	if($page eq ''){ $page = 1; }													# Makes page 1 the default page
	my $totalPages = ceil((scalar(@thisCategoryEntries))/$config_entriesPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_entriesPerPage*$page);									# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);							# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;

	my $i = $arrayStart;															# Start Looping...
	while($i<=$arrayEnd)
	{
		unless($thisCategoryEntries[$i] eq '')
		{
			my @finalEntries = split(/"/, $thisCategoryEntries[$i]);
			my @categories = split (/'/, $finalEntries[3]); #200513 Efia multiple categories
			my @pages = getPages();
			my $do = 1;
			foreach(@pages)
			{
				if($_ == $finalEntries[4])
				{
					$do = 0;
					last;
				}
			}
			
			if($do == 1)
			{
				$finalEntries[1] =~ s/&quot;/"/g; $finalEntries[1] =~ s/&apos;/'/g; #210613 jamesbond - undo quoting
				print '<h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><br />'.$finalEntries[1].'<br /><br /><center><i>Posted on '.$finalEntries[2].' by <b>'.$finalEntries[5].'</b> - Categories: '; 
				#200513 Efia linking to more than one category
				for (0..$#categories){ print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';}
				print '<br /><a href="?viewDetailed='.$finalEntries[4].'">Comments</a> - <a href="?edit='.$finalEntries[4].'">Edit</a> - <a href="?delete='.$finalEntries[4].'">Delete</a></i></center><br /><br />';
			}
		}
		$i++;
	}
	# Now i will display the pages
	if($totalPages >= 1)
	{
		print '<center> Pages: ';
	}
	else
	{
		print '<center> No posts under this category.';
	}
	
	my $startPage = $page == 1 ? 1 : ($page-1);
	my $displayed = 0;
	for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
	{
		if($i <= $totalPages)
		{
			if($page != $i)
			{
				if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
				{
					print '<a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
	print '</center>';
}
elsif(r('edit') ne '')
{
	# Edit Secure (This page will appear before the edit one)
		
	my $fileName = r('edit');
	#110712 UTF-8 fix
	print '<h1>Editing Entry...</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>User</td>
	<td><input name="user" type="text" id="user"></td>
	</tr>
	<tr>
	<td>Pass</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="editSecured">
	<input name="fileName" type="hidden" id="fileName" value="'.$fileName.'"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Edit Entry"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('process') eq 'editSecured')
{
	# Edit Entry Page
	my $user = r('user');
	my $pass = r('pass');
	my $auth = 0;
	my $administrator = 0;
	if(-s $config_adminPassFile && $user eq 'Admin')
	{
		
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
			$auth = 1;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
		$administrator = 1;
	}
	elsif(! -s $config_adminPassFile)
	{
		dienice("An Administrator Password must be set!");
	}
	else
	{
		# login and edit as user
		# Start of author checking, for identity security
		open(FILE, "<$config_postsDatabaseFolder/users.$config_dbFilesExtension.dat") or dienice("Could not open file.");
		my $data = '';
		while(<FILE>)
		{
			$data.=$_;
		}
		close(FILE);
		
		my @users = split(/"/, $data);
		foreach(@users)
		{
			my @data = split(/'/, $_);
			if($bloguser eq $data[0])
			{
				if(crypt($pass, $config_randomString) ne $data[1])
				{
					$auth = 0;
				}
				last;
			}
			$auth = 1;
			$administrator = 0;
		}
	}
	
	if($auth == 1)
	{
		my $id = r('fileName');
		my $tempContent = '';
		open(FILE, "<$config_postsDatabaseFolder/$id.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/"/, $tempContent);
		$entry[1] =~ s/&quot;/"/g; $entry[1] =~ s/&apos;/'/g; #210613 jamesbond - undo quoting
		my $fileName = $entry[4];
		my $title = $entry[0];
		my $content = $entry[1];
		my $category = $entry[3];
		my $author = $entry[5];
		if($administrator == 0)
		{
			if($user ne $author)
			{
				dienice("You are only allowed to edit your own posts!");
			}
		}
		#110712 UTF-8 fix
		print '<h1>Editing Entry...</h1>
		<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table>
		<tr>
		<td>Title</td>
		<td><input name=title type=text id=title value="'.$title.'"></td>
		</tr>';
		if($config_useHtmlOnEntries == 0)
		{
			print '<tr>
			<td>&nbsp;</td>
			<td><input type="button" style="width:35px;font-weight:bold;" onClick="surroundText(\'[b]\', \'[/b]\', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="width:35px;font-style:italic;" onClick="surroundText(\'[i]\', \'[/i]\', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="width:35px;text-decoration:underline;" onClick="surroundText(\'[u]\', \'[/u]\', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="width:35px" onClick="surroundText(\'[center]\', \'[/center]\', document.forms.submitform.content); return false;" value="<->" />
			<input type="button" style="width:35px" onClick="surroundText(\'[class=CLASS]\', \'[/class]\', document.forms.submitform.content); return false;" value="class" />
			<input type="button" style="width:35px" onClick="surroundText(\'[style=text-size:;color:]\', \'[/style]\', document.forms.submitform.content); return false;" value="style" />
			<input type="button" style="width:35px" onClick="surroundText(\'[url]\', \'[/url]\', document.forms.submitform.content); return false;" value="url" />
			<input type="button" style="width:35px" onClick="surroundText(\'[img]\', \'[/img]\', document.forms.submitform.content); return false;" value="img" />
			<input type="button" style="width:35px" onClick="surroundText(\'[code]\', \'[/code]\', document.forms.submitform.content); return false;" value="code" />'; #210613 #020713 added class
			#sc0ttman
			if($config_enableJQueryLightboxes == 1) { print '
			<input type="button" style="width:35px;" onClick="surroundText(\'[box]\', \'[/box]\', document.forms.submitform.content); return false;" value="box" />'; }
			print '</td>
			</tr>';
			# sc0ttman
		}
		else
		{
			print '<script src="http://js.nicedit.com/nicEdit.js" type="text/javascript"></script><script type="text/javascript">bkLib.onDomLoaded(nicEditors.allTextAreas);</script>' if($config_useWYSIWYG == 1);
		}		
		print '<tr><td>Content<br /><a href="?do=showSmilies" target="_blank">Show Smilies</a></td><td><textarea name=content cols='.$config_textAreaCols.'"';
		print ' style="height: 400px; width: 400px;" ' if( ($config_useWYSIWYG == 1) && ($config_useHtmlOnEntries == 1) );
		print ' rows="'.$config_textAreaRows.'" id="content">';
		if($config_useHtmlOnEntries == 0)
		{
			print bbdecode($content);
		}
		else
		{
			print $content;
		}
		print '</textarea></td></tr><tr><td>Category<br />(Available: ';
		my @categories = getCategories();
		my $i = 1;
		foreach(@categories)
		{
			if($i < scalar(@categories))	# Here we display a comma between categories so is easier to undesrtand
			{
				print $_.', ';
			}
			else
			{
				print $_;
			}
			$i++;
		}
		print ')</td>
		<td><input name="category" type="text" id="category" value="'.$category.'"></td>
		</tr>
		<tr>
		<td><input name="process" type="hidden" id="process" value="editEntry">
		<input name="fileName" type="hidden" id="fileName" value="'.$fileName.'">
		<input name="author" type="hidden" id="author" value="'.$author.'"></td>
		</tr>
		<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="Submit" value="Save Entry"></td>
		</tr>
		</table>
		</form>';
	}
}
elsif(r('process') eq 'editEntry')
{
	my $author = r('author');
	my $title = r('title');
	my $content = '';
	if($config_useHtmlOnEntries == 0)
	{
		$content = bbcode(r('content'));
	}
	else
	{
		$content = basic_r('content');
	}
	my $category = r('category');
	my $fileName = r('fileName');
	
	open(FILE, "+>$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
	
	if($title eq '' or $content eq '' or $category eq '')
	{
		dienice("All fields are neccesary!");
	}
	
	my $date = getdate($config_gmt);
	print FILE $title.'"'.$content.'"'.$date.'"'.$category.'"'.$fileName.'"'.$author;	# 0: Title, 1: Content, 2: Date, 3: Category, 4: FileName, 5: Author
	print '<center>Thanks "'.$author.'". Your post "'.$title.'" has been updated.<br /><a href="?viewDetailed='.$fileName.'">Go Back</a></center>'; #sc0ttman
	close FILE;
	
}
elsif(r('delete') ne '')
{
	# Delete Entry Page
	
	my $fileName = r('delete');
	#110712 UTF-8 fix
	print '<h1>Deleting Entry...</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>Admin Pass</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="deleteEntry">
	<input name="fileName" type="hidden" id="fileName" value="'.$fileName.'"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Delete Entry"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('process') eq 'deleteEntry')
{
	# Delete Entry Process
	
	my $pass = r('pass');
	my $auth = 0;
	if(-s $config_adminPassFile)
	{
		
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
		else
		{
			$auth = 1;
		}
	}
	if($auth == 1)
	{
		my $fileName = r('fileName');
		my @pages = getPages();
		my $isPage = 0;
		foreach(@pages)
		{
			if($_ == $fileName)
			{
				$isPage = 1;
				last;
			}
		}
		
		my $newPages;
		if($isPage == 1)
		{
			foreach(@pages)
			{
				if($_ != $fileName)
				{
					$newPages.=$_.'-';
				}
			}
			
			open(FILE, "+>$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
			print FILE $newPages;
			close FILE;
		}
		
		unlink("$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");		
		print 'Entry deleted. <a href="?page=1">Go to Index</a>';
	}
	else
	{
		print '<center>Wrong password!</center>';
	}
}
elsif(r('do') eq 'search')
{
	# Search Function

	my $keyword = r('keyword');
	my $do = 1;
	
	if(length($keyword) < $config_searchMinLength)
	{
		print 'The keyword must be at least '.$config_searchMinLength.' characters long!';
		$do = 0;
	}
	
	my $by = r('by');							# This can be 0 (by title) or 1 (by id) based on the splitted array
	#if(($by != 0) && (($by != 1) || ($by != 5))){ $by = 0; }	# Just prevention from CURL or something...
	# add 'Author' 160316
	my $sBy = '';
	if($by == 0)
	{
		 $sBy = 'Title';
	}
	elsif($by == 1)
	{
		 $sBy = 'Content';
	}
	elsif($by == 5)
	{
		$sBy = 'Author';
	}
	if($do == 1)
	{
		print 'Searching for '.$keyword.' by '.$sBy.'...<br /><br />';
		my @entries = getFiles($config_postsDatabaseFolder);
		my $matches = 0;
		foreach(@entries)
		{
			my @currEntry = split(/"/, $_);
			if(($currEntry[$by] =~ m/$keyword/i))
			{
				print '<a href="?viewDetailed='.$currEntry[4].'">'.$currEntry[0].'</a><br />';
				$matches++;
			}
		}
		print '<br /><center>'.$matches.' Matches Found.</center>';
	}
}
elsif(r('viewDetailed') ne '')
{
	# Display Individual Entry
	
	my $fileName = r('viewDetailed');
	my $do = 1;
	
	unless(-e "$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension")
	{
		print 'Sorry, that entry does not exists or it has been deleted.';
		$do = 0;
	}
	
	# First Display Entry
	if($do == 1)		# Checks if the file exists before doing all this
	{
		my $tempContent;
		open(FILE, "<$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/"/, $tempContent);
		my $fileName = $entry[4];
		my $title = $entry[0];
		my $content = $entry[1];
		my $author = $entry[5];
		my @categories = split (/'/, $entry[3]); #200513 Efia linking to more than one category
		print '<h1><a href="?viewDetailed='.$entry[4].'">'.$entry[0].'</a></h1><br />'.$entry[1].'<br /><br /><center><i>Posted on '.$entry[2].' by <b>'.$entry[5].'</b> - Categories: ';
		for (0..$#categories){print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> '; } 
		print '<br /><a href="?edit='.$entry[4].'">Edit</a> - <a href="?delete='.$entry[4].'">Delete</a></i></center><br /><br />';
		
		# Now Display Comments
		unless(-d $config_commentsDatabaseFolder)		# Does the comments folder exists? We will save comments there...
		{
			mkdir($config_commentsDatabaseFolder, 0755);
		}
	
		my $content = '';
		open(FILE, "<$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content.=$_;
		}
		close FILE;
		
		if($content eq '')
		{
			print 'No comments posted yet.';
		}
		else
		{
			print '<h1>Comments:</h1>';
			
			my @comments = split(/'/, $content);
			
			if($config_commentsDescending == 1)
			{
				@comments = reverse(@comments);			# We want the newest first? (Edit at the top on the configuration if you do want newest first)
			}
			
			my $i = 0;
			foreach(@comments)
			{
				my @comment = split(/"/, $_);
				$comment[2] =~ s/&quot;/"/g; $comment[2] =~ s/&apos;/'/g; #210613 jamesbond - undo quoting  
				my $title = $comment[0];
				my $author = $comment[1];
				my $content = $comment[2];
				my $date = $comment[3];
				my $anchor = $comment[5]; #020313
				print '<a id="anchor" name="'.$anchor.'" href="?viewDetailed='.$fileName.'#'.$anchor.'" title="\''.$title.'\' by '.$author.'"></a>Posted on <b>'.$date.'</b> by <b>'.$author.'</b><br /><i>"'.$title.'"</i><br />'; #020313
				if($config_bbCodeOnCommentaries == 0)
				{
					print txt2html($content);
				}
				else
				{
					print bbcode($content);
				}
				print '<br /><a href="?deleteComment='.$fileName.'.'.$i.'">Delete</a><br /><br />';
				$i++;	# This is used for deleting comments, to i know what comment number is it :]
			}
		}
		# Add comment form
		if($config_allowComments == 1)
		{
			#110712 UTF-8 fix
			print '<br /><br /><h1>Add Comment</h1>
			<form accept-charset="UTF-8" name="submitform" method="post">
			<table>
			<tr>
			<td>Title</td>
			<td><input name="title" type="text" id="title"></td>
			</tr>
			<tr>
			<td>Author</td>
			<td><input name="author" type="text" id="author"></td>
			</tr>';
			
			print '<tr>
			<td>&nbsp;</td>
			<td><input type="button" style="width:35px;font-weight:bold;" onClick="surroundText(\'[b]\', \'[/b]\', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="width:35px;font-style:italic;" onClick="surroundText(\'[i]\', \'[/i]\', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="width:35px;text-decoration:underline;" onClick="surroundText(\'[u]\', \'[/u]\', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="width:35px;" onClick="surroundText(\'[url]\', \'[/url]\', document.forms.submitform.content); return false;" value="url" />
			<input type="button" style="width:35px;" onClick="surroundText(\'[img]\', \'[/img]\', document.forms.submitform.content); return false;" value="img" />
			<input type="button" style="width:35px;" onClick="surroundText(\'[code]\', \'[/code]\', document.forms.submitform.content); return false;" value="code" />';
			# sc0ttman
			if($config_enableJQueryLightboxes == 1) { print '
			<input type="button" style="width:35px;" onClick="surroundText(\'[box]\', \'[/box]\', document.forms.submitform.content); return false;" value="box" />'; }
			print '</td>
			</tr>' if $config_allowBBcodeButtonsOnComments == 1 && $config_bbCodeOnCommentaries == 1;
			# sc0ttman
			
			print '<tr>
			<td>Content<br /><a href="?do=showSmilies" target="_blank">Show Smilies</a></td>
			<td><textarea name="content" id="content" cols="'.$config_textAreaCols.'" rows="'.$config_textAreaRows.'"></textarea></td>
			</tr>
			<tr>';
			
			if($config_commentsSecurityCode == 1)
			{
				my $code = '';
				if($config_onlyNumbersOnCAPTCHA == 1)
				{
					$code = substr(rand(999999),1,$config_CAPTCHALength);
				}
				else
				{
					$code = uc(substr(crypt(rand(999999), $config_randomString),1,$config_CAPTCHALength));
				}
				$code =~ s/\.//;
				$code =~ s/\///;
				print '<td>Security Code</td>
				<td><font face="Verdana, Arial, Helvetica, sans-serif" size="2">'.$code.'</font><input name="originalCode" value="'.$code.'" type="hidden" id="originalCode"></td>
				</tr>
				<tr>
				<td></td>
				<td><input name="code" type="text" id="code"></td>
				</tr>';
			}
			
			print '<tr>
			<td>'.$config_commentsSecurityQuestion.'</td>
			<td><input name="question" type="text" id="question"></td>
			</tr>
			<tr>' if $config_securityQuestionOnComments == 1;
			
			print '<tr>
			<td>Password (to protect your identity)</td>
			<td><input name="pass" type="password" id="pass"></td>
			</tr>
			<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="Submit" value="Add Comment"><input name="sendComment" value="'.$fileName.'" type="hidden" id="sendComment"></td>
			</tr>
			</table>
			</form>';
		}
	}
}
elsif(r('sendComment') ne '')
{
	# Send Comment Process
	
	my $fileName = r('sendComment');
	my $title = r('title');
	my $author = r('author');
	my $content = r('content');
	my $pass = r('pass');
	my $date = getdate($config_gmt);
	my $anchor = strftime "%Y%m%d%H%M%S", localtime; #020313
	my $do = 1;
	my $triedAsAdmin = 0;
	
	$content =~ s/'/&apos;/g; $content =~ s/"/&quot;/g; # jamesbond 20130323 #210613
	$title =~ s/'/&apos;/g; $title =~ s/"/&quot;/g; # jamesbond 20130323	#210613
	if($title eq '' || $author eq '' || $content eq '' || $pass eq '')
	{
		print 'All fields are neccessary. Go back and fill them all.';
		$do = 0;
	}
	
	if($config_commentsSecurityCode == 1)
	{
		my $code = r('code');
		my $originalCode = r('originalCode');
		
		unless($code eq $originalCode)
		{
			print 'Security Code does not match. Please, try again.';
			$do = 0;
		}
	}
	
	if($config_securityQuestionOnComments == 1)
	{
		my $question = r('question');
		unless(lc($question) eq lc($config_commentsSecurityAnswer))
		{
			print 'Incorrect security answer. Please, try again.';
			$do = 0;
		}
	}
	
	my $hasPosted = 0;					# This is to see if the user has posted already, so we add him/her to the database :]
	
	foreach(@config_commentsForbiddenAuthors)
	{
		if($_ eq $author)
		{
			my tryPass = crypt($pass, $config_randomString);
			open(FILE, "<$config_adminPassFile");
			my $adminPass = '';
			while(<FILE>)
			{
				$adminPass.=$_;
			}
			close(FILE);
			
			unless($tryPass eq $adminPass)		# Prevent users from using nicks like "admin"
			{
				$do = 0;
				dienice("Wrong password for using '.$_.' as nickname");
				last;
			}
			else
			{
				$hasPosted = 1;
			}
			$triedAsAdmin = 1;
		}
	}
	
	# Start of author checking, for identity security
	open(FILE, "<$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
	my $data = '';
	while(<FILE>)
	{
		$data.=$_;
	}
	close(FILE);
	
	if($triedAsAdmin == 0)
	{
		my @users = split(/"/, $data);
		foreach(@users)
		{
			my @data = split(/'/, $_);
			if($author eq $data[0])
			{
				$hasPosted = 1;
				if(crypt($pass, $config_randomString) ne $data[1])
				{
					$do = 0;
					print 'The username '.$author.' is already taken and that password is incorrect. Please choose other author or try again.';
				}
				last;
			}
		}
	}
	
	if($hasPosted == 0)
	{
		if ($config_commentsRequireRegistration == 1)
		{
			dienice("Sorry $author. You can not post a comment without registering first. See the <a href=?do=reg><i>Register</i></a> link in the Main Menu.");
		}
		else	
		{
			open(FILE, ">>$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
			print FILE $author."'".crypt($pass, $config_randomString).'"';
			close FILE;
			print 'You are a new user posting here... You will be added to a database so nobody can steal your identity. Remember your password!<br>';
		}
	}
	# End of author checking, start adding comment
	
	if($do == 1)
	{	
		if($title eq '' or $author eq '' or $content eq '')
		{
			print 'All fields are neccessary.';
		}
		else
		{
			if(length($content) > $config_commentsMaxLenght)
			{
				print 'The content is too long! Max characters is '.$config_commentsMaxLenght.' you typed '.length($content);
			}
			else
			{
				my $content = $title.'"'.$author.'"'.$content.'"'.$date.'"'.$fileName.'"'.$anchor."'"; #020313
				
				# Add comment
				open(FILE, ">>$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
				print FILE $content;
				close FILE;
				
				# Add coment number to a file with latest comments				
				open(FILE, ">>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
				print FILE $content;
				close FILE;
				
				print '<center>Comment added. Thanks '.$author.'!<br /><a href="?viewDetailed='.$fileName.'">Go Back</a></center>'; #sc0ttman
				
				# If Comment Send Mail is active
				if($config_sendMailWithNewComment == 1)
				{
					my $content = "Hello, i am sending this mail beacuse $author commented on your blog: http://".$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'}."\nTitle: $title\nComment: $content\nDate: $date\n\nRemember you can disallow this option changing the ".'$config_sendMailWithNewComment Variable to 0';
					open (MAIL,"|/usr/sbin/sendmail -t");
					print MAIL "To: $config_sendMailWithNewCommentMail\n";
					print MAIL "From: SJPPLOG_NG \n";
					print MAIL "Subject: New Comment on your SJPPLOG_NG Blog\n\n";
					print MAIL $content;
					close(MAIL);
				}
			}
		}
	}
}
elsif(r('deleteComment') ne '')
{
	# Delete Comment
	
	my $data = r('deleteComment');
	
	#110712 UTF-8 fix
	print '<h1>Deleting Comment...</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>Pass</td>
	<td><input name="pass" type="password" id="pass">
	<input name="process" type="hidden" id="process" value="deleteComment">
	<input name="data" type="hidden" id="data" value="'.$data.'"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="Submit" value="Delete Entry"></td>
	</tr>
	</table>
	</form>';
}
elsif(r('process') eq 'deleteComment')
{
	# Delete Comment Process
	
	my $pass = r('pass');
	my $auth = 0;
	if(-s $config_adminPassFile)
	{
		
		# authenticate adminPass
		open(FILE, "<$config_adminPassFile");
		my $adminPass = '';
		while(<FILE>)
		{
			$adminPass.=$_;
		}
		close(FILE);
		if(crypt($pass, $config_randomString) ne $adminPass)
		{
			dienice("Passwords do not match!");
		}
		else
		{
			$auth = 1;
		}
	}
	if($auth == 1)
	{
		my $data = r('data');
		my @info = split(/\./, $data);
		my $fileName = $info[0];
		my $part = $info[1];
		my $commentToDelete;
		
		my $content = '';
		open(FILE, "<$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content.=$_;
		}
		close FILE;
		
		my @comments = split(/'/, $content);
		
		if($config_commentsDescending == 1)
		{
			@comments = reverse(@comments);
		}
		
		my $newContent = '';
		
		my $i = 0;
		my @newComments;
		foreach(@comments)
		{
			if($i != $part)
			{
				push(@newComments, $_);
			}
			else
			{
				$commentToDelete = $_;
			}
			$i++;
		}
		
		if($i == 1)		# There was only 1 comment
		{
			unlink("$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
		}
		else
		{		
			reverse(@newComments);
			
			foreach(@newComments)
			{
				$newContent.=$_."'";
			}
			
			open(FILE, "+>$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");	# Open for writing, and delete everything else
			print FILE $newContent;
			close FILE;
		}
		
		# Now delete comment from the latest comments file where all comments are saved
		open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
		$newContent = '';
		while(<FILE>)
		{
			$newContent.=$_;
		}
		close FILE;
		
		my @comments = split(/'/, $newContent);
		my $finalCommentsToAdd;
		foreach(@comments)
		{
			unless($_ eq $commentToDelete)
			{
				$finalCommentsToAdd.=$_."'";
			}
		}
		
		open(FILE, "+>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");	# Open for writing, and delete everything else
		print FILE $finalCommentsToAdd;
		close FILE;
		
		# Finally print this
		print '<center>Comment Deleted.<br /><a href="?viewDetailed='.$fileName.'">Go Back</a></center>'; # sc0ttman
	}
	else
	{
		print '<center>Wrong password!</center>';
	}
}
elsif(r('do') eq 'archive')
{
	# Show blog archive
	
	print '<h1>Archive</h1>';
	my @entries = getFiles($config_postsDatabaseFolder);
	print 'No entries created yet.' if scalar(@entries) == 0;
	# Split the data in the post so i have them in this format "13 Dic 2008, 24:11|0001|Entry title" date|fileName|entryTitle
	my @dates = map { my @stuff = split(/"/, $_); @stuff[2].'|'.@stuff[4].'|'.@stuff[0]; } @entries; #210613
	my @years;
	foreach(@dates)
	{
		my @date = split(/\|/, $_);
		my @y = split(/\s/, $date[0]);
		$y[2] =~ s/,//;
		if($y[2] =~ /^\d+$/)
		{
			push(@years, $y[2]);
		}
	}
	@years = reverse(sort(array_unique(@years)));
	
	# Efia new Archive
	my $page = r('p');
	if ($page eq ''){$page = 1;}
	my $i = ($page - 1);
	my $totalPages = scalar@years;
	
	if ($years[$i]){
		print "<h1><small>$years[$i]</small></h1>";
		my @months = qw(Dic Nov Oct Sep Aug Jul Jun May Apr Mar Feb Jan);
		my %print = (Jan=>"January", Feb=>"February", Mar=>"March", Apr=>"April", May=>"May", 
		Jun=>"June", Jul=>"July", Aug=>"August", Sep=>"September", Oct=>"October", Nov=>"November", Dic=>"December");
		
		for my $actualMonth(@months){ 
			my @entries = grep{/$actualMonth\s$years[$i]/}@dates;
			next if scalar @entries ==0;
			@entries = sort {$a<=>$b}reverse(@entries);
			print '<b>'.$print{$actualMonth}.' ('.scalar @entries.' entries)</b><table>';
			
			foreach (@entries){
				my @e = split(/\|/,$_);
				my @d = split(/\s/,$e[0]);
				print '<tr><td style="text-align:right">'.$d[0].'</td><td><a href="?viewDetailed='.$e[1].'">'.$e[2].'</a></td></tr>';
				}
				print "</table><br />";
			}
		}
		if ($totalPages >= 1){ 
			print "<br />Year: ";
			$i = 0;
			while ($years[$i]) {
				my $j = ($i+1);
				print '<a href="?do=archive&p='.$j.'">'.$years[$i].'</a> ';
				$i++;
			}	
		}
		else {print "No posts in archive!";}		
}#Efia
elsif(r('do') eq 'listComments')
{
	print '<h1>Listing All Comments</h1>';
	my @comments = getComments();
	# This is pagination... Again :]
	my $page = r('page');												# The current page
	if($page eq ''){ $page = 1; }										# Makes page 1 the default page (Could be... $page = 1 if $page eq '')
	my $totalPages = ceil((scalar(@comments))/$config_commentsPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_commentsPerPage*$page);						# The array will start from this number
	my $arrayStart = $arrayEnd-($config_commentsPerPage-1);				# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;
	my $i = $arrayStart;												# Start Looping...
	if(scalar(@comments) > 0)
	{
		print '<table width="100%"><tr><td><i>Comment Title</i></td><td><i>Comment Author</i></td></tr>';
	}
	else
	{
		print 'No comments posted yet.';
	}
	while($i<=$arrayEnd)
	{
		unless($comments[$i] eq '')
		{
			my @finalEntries = split(/"/, $comments[$i]);
			my @pages = getPages();
			my $do = 1;
			foreach(@pages)
			{
				if($_ == $finalEntries[4])
				{
					$do = 0;
					last;
				}
			}
			
			if($do == 1)
			{
				print '<tr><td><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></td><td><b>'.$finalEntries[1].'</b></td></tr>';
			}
		}
		$i++;
	}
	# Now i will display the pages
	print '</table><center> Pages: ' if scalar(@comments) > 0;
	my $startPage = $page == 1 ? 1 : ($page-1);
	my $displayed = 0;
	for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
	{
		if($i <= $totalPages)
		{
			if($page != $i)
			{
				if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
				{
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
	print '</center>';
}
elsif(r('do') eq 'showSmilies')
{
	if(-d "$config_smiliesFolder")
	{
		if(opendir(DH, $config_smiliesFolder))
		{
			my @smilies;
			print '<h1>Smilies</h1><table width="100%"><tr><td>Smilie</td><td>Code</td></tr>';
			@smilies = grep {/gif/ || /jpg/ || /png/;} readdir(DH);
			foreach(@smilies)
			{
				my @n = split(/\./, $_);
				print '<tr><td><img src="'.$config_imgFilesFolder.'/'.$config_smiliesFolderName.'/'.$_.'" /></td><td>:'.$n[0].':</td></tr>';
			}
			print '</table>';
		}
		else
		{
			print 'Error opening '.$config_smiliesFolder.' folder.';
		}
	}
	else
	{
		print 'The admin owner did not allow smilies for this blog.';
	}
}
else
{
	# Blog Main Page
	my @entries = getFiles($config_postsDatabaseFolder);
	if(scalar(@entries) != 0)
	{
		# Pagination - This is the so called Pagination
		my $page = r('page');												# The current page
		if($page eq ''){ $page = 1; }										# Makes page 1 the default page
		my $totalPages = ceil((scalar(@entries))/$config_entriesPerPage);	# How many pages will be?
		# What part of the array should i show in the page?
		my $arrayEnd = ($config_entriesPerPage*$page);						# The array will start from this number
		my $arrayStart = $arrayEnd-($config_entriesPerPage-1);				# And loop till this number
		# As arrays start from 0, i will lower 1 to these values
		$arrayEnd--;
		$arrayStart--;

		my $i = $arrayStart;												# Start Looping...
		while($i<=$arrayEnd)
		{
			unless($entries[$i] eq '')
			{
				my @finalEntries = split(/"/, $entries[$i]);
				my @categories = split (/'/, $finalEntries[3]); #200513 Efia multiple categories
				my @pages = getPages();
				my $do = 1;
				foreach(@pages)
				{
					if($_ == $finalEntries[4])
					{
						$do = 0;
						last;
					}
				}
				
				if($do == 1)
				{
					# This is for displaying how many comments are posted on that entry
					my $commentsLink;
					my $content;
					open(FILE, "<$config_commentsDatabaseFolder/$finalEntries[4].$config_dbFilesExtension");
					while(<FILE>){$content.=$_;}
					close FILE;
					
					my @comments = split(/'/, $content);
					if(scalar(@comments) == 0)
					{
						$commentsLink = 'No comments';
					}
					elsif(scalar(@comments) == 1)
					{
						$commentsLink = '1 Comment';
					}
					else
					{
						$commentsLink = scalar(@comments).' Comments';
					}
					
					$finalEntries[1] =~ s/&quot;/"/g; $finalEntries[1] =~ s/&apos;/'/g; #210613 jamesbond - undo quoting
					print '<h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><br />'.$finalEntries[1].'<br /><br /><center><i>Posted on '.$finalEntries[2].' by <b>'.$finalEntries[5].'</b> - Categories: ';
					#200513 Efia linking to more than one category
					for (0..$#categories){print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> '; }
					print'<br /><a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.'</a> - <a href="?edit='.$finalEntries[4].'">Edit</a> - <a href="?delete='.$finalEntries[4].'">Delete</a></i></center><br /><br />';
				}
			}
			$i++;
		}
		# Now i will display the pages
		print '<center> Pages: ';
		my $startPage = $page == 1 ? 1 : ($page-1);
		my $displayed = 0;
		for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
		{
			if($i <= $totalPages)
			{
				if($page != $i)
				{
					if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
					{
						print '<a href="?page='.$i.'">['.$i.']</a> ...';
					}
					elsif($startPage > 1 && $displayed == 0)
					{
						print '... <a href="?page='.$i.'">['.$i.']</a> ';
						$displayed = 1;
					}
					else
					{
						print '<a href="?page='.$i.'">['.$i.']</a> ';
					}
				}
				else
				{
					print '['.$i.'] ';
				}
			}
		}
		print '</center>';
	}
	else
	{
		print 'No entries created. Why dont you <a href="?do=newEntry">make one</a>?';
	}
}
print '</div></div><div id="footer">&copy; Copyright '.$config_blogTitle.' and respective Authors '.$config_enableYear.' - All Rights Reserved<br> '.$config_licenceMessage.'<br>';
foreach(@config_licenceMessageExtra) 
{
	print $_.' <br>';
}
print $config_licenceImage.'<br>';
print 'Powered by <a href="https://github.com/01micko/sjpplog_ng">SJPPLOG_NG</a>'; 
print '<br>All posts are using GMT '.$config_gmt if $config_showGmtOnFooter == 1; print '</div>';
print '<noscript><p style="text-align:center;">This page is best viewed with Javascript enabled</noscript>';
print '</body></html>';
}
