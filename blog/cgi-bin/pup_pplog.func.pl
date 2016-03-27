# Basic Functions
sub r
{
	escapeHTML(param($_[0]));
}

sub basic_r
{
	param($_[0]);
}

sub bbcode
{
	$_ = $_[0];
	s/\n/<br \/>/gi;
	s/\[b\](.+?)\[\/b\]/<b>$1<\/b>/gi;
	s/\[i\](.+?)\[\/i\]/<i>$1<\/i>/gi;
	s/\[u\](.+?)\[\/u\]/<u>$1<\/u>/gi;
	s/\[\*\](.+?)\[\/\*\]/<li>$1<\/li>/gi;
	# sc0ttman BOF - note, the [url] tag must come later
	s/\[img\](https?:\/\/.*?.*?)\[\/img\]/<img src=$1 \/>/gi; ## https?:\/\/.*?.*? matches whole URL ... apparently..
	s/\[img\](.+?)\[\/img\]/<img src=$config_imgFilesFolder\/$1 \/>/gi;
	#s/\[box\]*(https?:\/\/.*?youtube\.com\/.*?)\[\/box\]/<a href=$1 rel=prettyPhoto>$1<\/a>/gi; # matches only youtube URLs
	s/\[box\]*(https?:\/\/.*?)\[\/box\]/<a href=$1 rel=prettyPhoto>$1<\/a>/gi;
	s/\[box\](.+?)\[\/box\]/<a href=$config_imgFilesFolder\/$1 rel=prettyPhoto><img rel=prettyPhoto src=$config_imgThumbsFolder\/$1 \/><\/a>/gi;
	s/\[code\](.+?)\[\/code\]/<pre class=code><code class=highlight>$1<\/code><\/pre>/gi;
	# sc0ttman EOF
	s/\[center\](.+?)\[\/center\]/<center>$1<\/center>/gi;
	s/\[url\](.+?)\[\/url\]/<a href=$1 target=_blank>$1<\/a>/gi;
	s/\[url=(.+?)\](.+?)\[\/url\]/<a href=$1 target=_blank>$2<\/a>/gi;
	s/\[quote\](.+?)\[\/quote\]/<div class=quote>$1<\/div>/gi;
	s/\[style=(.+?)\](.+?)\[\/style\]/<div style=$1>$2<\/div>/gi; #210613 efiabruni styles
	s/\[class=(.+?)\](.+?)\[\/class\]/<span class=$1>$2<\/span>/gi; #020713 james class
	if(-d "$config_smiliesFolder")
	{
		my @smilies;
		my $s;
		if(opendir(DH, $config_smiliesFolder))
		{
			@smilies = grep {/gif/ || /jpg/ || /png/;} readdir(DH);
		}
		foreach $s(@smilies)
		{
			my @i = split(/\./, $s);
			s/\:$i[0]\:/<img src=$config_imgFilesFolder\/$config_smiliesFolderName\/$i[0].$i[1] \/>/gi;
		}
	}
	return $_;
}

sub bbdecode
{
	$_ = $_[0];
	s/\n//;
	s/<br \/>//gi;
	s/\<b\>(.+?)\<\/b\>/\[b\]$1\[\/b\]/gi;
	s/\<i\>(.+?)\<\/i\>/\[i\]$1\[\/i\]/gi;
	s/\<u\>(.+?)\<\/u\>/\[u\]$1\[\/u\]/gi;
	s/\<li\>(.+?)\<\/li\>/\[\*\]$1\[\/\*\]/gi;
	# sc0ttman BOF -  - note, the [url] tag must come later.... 
	s/\<img src=(https?:\/\/.*?) \/>/\[img\]$1\[\/img\]/gi;
	s/\<img src=(.+?)\/([^\/]+\.[^.]+) \/>/\[img\]$2\[\/img\]/gi;  #160316 filename only
	#s/\<img src=(?:.*?\/)?(.+?) \/>/\[img\]$1\[\/img\]/gi; #210613
	s/\<a href=(?:.*\/)?(.+?)\ rel=prettyPhoto\>\<img rel=prettyPhoto src=(.+?) \/>\<\/a\>/\[box\]$1\[\/box\]/gi; # (?:.*\/)? before (.+?) shows filename only #210613 #160316
	#s/\<a href=(https?:\/\/.*?youtube\.com\/.*?)\ rel=prettyPhoto\>(.+?)\<\/a\>/\[box\]$1\[\/box\]/gi; # matches youtube URLs
	s/\<a href=(https?:\/\/.*?)\ rel=prettyPhoto\>(.+?)\<\/a\>/\[box\]$1\[\/box\]/gi;
	s/\<pre class=code\>\<code class=highlight\>(.+?)\<\/code\>\<\/pre\>/\[code\]$1\[\/code\]/gi;
	# sc0ttman EOF
	s/\<center\>(.+?)\<\/center\>/\[center\]$1\[\/center\]/gi;
	s/\<a href=(.+?)\ target=_blank\>(.+?)\<\/a\>/\[url=$1\]$2\[\/url\]/gi;
	s/\<div class=quote\>(.+?)\<\/div\>/\[quote\]$1\[\/quote\]/gi;
	s/\<div style=(.+?)\>(.+?)\<\/div\>/\[style=$1\]$2\[\/style\]/gi; #210613 efiabruni styles
	s/\<span class=(.+?)\>(.+?)\<\/span\>/\[class=$1\]$2\[\/class\]/gi; #020713 james class
	return $_;
}

sub txt2html
{
	$_ = $_[0];
	s/\n/<br \/>/gi;
	return $_;
}

sub getdate
{
	my $gmt = $_[0];
	my $epoch = time() + $gmt*60*60;
	my $tt = strftime "%e %b %Y, %H:%M\n", gmtime($epoch);
	$tt =~ s/^\s+|\s+$//g;
	return $tt;
}

sub array_unique
{
	my %seen = ();
	@_ = grep { ! $seen{ $_ }++ } @_;
}

sub getFiles			# This function returns all files from the db folder
{
	if(!(opendir(DH, $_[0])))
	{
		mkdir($config_postsDatabaseFolder, 0755);
	}
	
	my @entriesFiles = (); 		# This one has all files names
	my @entries = (); 			# This one has the content of all files not splitted
	
	foreach(readdir DH)
	{
		unless($_ eq '.' or $_ eq '..' or (!($_ =~ /$config_dbFilesExtension$/)))
		{
			push(@entriesFiles, $_);
		}
	}
	
	@entriesFiles = sort{$b <=> $a}(@entriesFiles);		# Here I order the array in descending order so i show Newest First
	
	foreach(@entriesFiles)
	{
		my $tempContent = '';
		open(FILE, "<".$_[0]."/$_");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		push(@entries, $tempContent);
	}
	return @entries;
}

sub getCategories		# This function is to get the categories not repeated in one array
{
	my @categories = ('General');
	my @tempCategories = ();
	if(-d "$config_postsDatabaseFolder")
	{
		my @entries = getFiles($config_postsDatabaseFolder);
		foreach(@entries)
		{
			my @finalEntries = split(/"/, $_); #"
			#200513 add multiple categories
			my @split = split(/'/, $finalEntries[3]); #'
			push(@tempCategories, @split);
		}
		@categories = array_unique(@tempCategories);
	}
	return @categories;
}

sub getPages
{
	open (FILE, "<$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
	my $pagesContent;
	while(<FILE>)
	{
		$pagesContent.=$_;
	}
	close FILE;
	
	my @pages = split(/-/, $pagesContent);
}

sub getComments
{
	open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
	my $content;
	while(<FILE>)
	{
		$content.=$_;
	}
	close(FILE);
	
	my @comments = split(/'/, $content);	#'
	@comments = reverse(@comments);			# We want newer first right?
}

sub dienice {
	print @_;
	exit 1;
}
# sc0ttman BOF
sub getStyles		# This function is to get the style*.css files in $config_currentStyleFolder
{
	# search in a few places, to get around different setups
	opendir(DIR, "$config_wwwEditFolder/$config_currentStyleFolder") or dienice("Can't open dir $config_wwwEditFolder/$config_currentStyleFolder");
	my @styles = grep {/style.*?\.css/} readdir DIR; # get only "style*.css" files from DIR
	my @styles = sort(@styles);
	closedir(DIR);
	return @styles;
}

sub fixMissingStyles   #020713
{
	if ( !-f "$config_wwwEditFolder/$config_currentStyleFolder/$config_currentStylesheet" )
	{
		our $missing_stylesheet = "$config_currentStylesheet";
		our $config_currentStylesheet = 'style1.css'; #set as default
		return 1;
	}
	else
	{
		return 0;
	}
}

# sc0ttman EOF
return 1;
