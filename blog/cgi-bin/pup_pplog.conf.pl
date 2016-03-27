# Main PPLOG Configuration. Please note the 1 and 0 options.. 1=Yes... and... 0=No
#
our $config_blogTitle = 'The Blog';															# Blog title
our $config_adminPass = 'Password1';												# Admin password for adding entries
our $config_blogStart = 'Mar 2016';												# date the blog commenced - optional
## sc0ttman BOF
our $config_wwwFolder = '/my/path/on/server/puppyblog/www/blog';		# Path to webserver root directory
#our $config_wwwEditFolder = '/maybe/a/different/path/public_html/puppyblog';		# Path if different to above for css (see the func file)
our $config_JSFilesFolder = '/www/blog/js';														# javascripts folder
our $config_imgFilesFolder = '/www/blog/images';											# images folder - where you upload your images
our $config_imgThumbsFolder = '/www/blog/thumbs';									# images thumbnail.. NOTE: use same filenames as the full size images!
our $config_currentStyleFolder = '/www/blog/css';											# Styles folder (. = in the same path as this file)
our $config_currentFavicon = '/www/blog/css/default/logo.png';				#favicon path
our $config_currentStylesheet = 'style1.css';											# filename of the style sheet in $config_currentStyleFolder
our $config_smiliesFolder = $config_wwwFolder.'/images/smilies'; # Path to smilies, optional
our $config_postsDatabaseFolder = $config_wwwFolder.'/posts'; # folder where entries (posts) will be saved
our $config_commentsDatabaseFolder = $config_wwwFolder.'/comments'; # folder where comments will be saved
our $config_enableStyleSelect = 0;												# enable user switching of stylesheets
our $config_enableJQuery = 1;														# enable jQuery; MUST be 1 for "syntax highlighting" and "lightboxes"
our $config_enableJQueryCDN = 1;												#020313 enable jQuery from content delivery network, not local files; requires $config_enableJQuery set to 1
our $config_enableJQueryCodeHighlighting = 1;							# enable syntax highlighting; requires $config_enableJQuery set to 1
our $config_enableJQueryCodeHighlightingCDN = 1;							# load the js from CDN for the syntax highlighting; requires $config_enableJQuery set to 1
our $config_enableJQueryLightboxes = 1;									# enable lightboxes on the [box] tag; needs $config_enableJQuery set to 1
our $config_enableJQueryLightboxesCDN = 1;									# load the JS from a CDN for lightboxes on the [box] tag; needs $config_enableJQuery set to 1
our $config_enableUploadPage = 1;									# enable a page for the site admin, to upload to imgs, thumbnails css dirs
our $config_enableYear = 2016;										#copyright year
## sc0ttman EOF
our $config_smiliesFolderName = 'smilies';									# Smilies Folder Name, DO NOT change this...
our $config_dbFilesExtension = 'ppl';												# Extension of the files used as databases
## secure password
our $config_adminPassFile = $config_wwwFolder.'/secure/admin.ppl';		#main admin password DO NOT change this...
our $config_entriesPerPage = 10;													# For pagination... How many entries will be displayed per page?
our $config_showPageCheckbox = 0;											#checkbox for pages
our $config_maxPagesDisplayed = 5;											# Maximum number of pages displayed at the bottom
our $config_metaRevisitAfter = 1;												# for search engines... How often to check for updates, in days
our $config_metaDescription = 'My Blog';						# Also for search engines
our $config_metaKeywords = 'blog, posts, pplog';							# Also for search engines...
our $config_textAreaCols = 50;														# Cols of the textarea to add and edit entries
our $config_textAreaRows = 10;													# Rows of the textarea to add and edit entries
our @config_ipBan = qw/202.325.35.145 165.265.26.65/;					# banned IPs... Just edit this, separate ips with spaces
our $config_bannedMessage = 'Sorry, you have been banned.';	# This message will appear when an user is banned from the blog
our $config_allowComments = 1;													# Allow user comments
our $config_bbCodeOnCommentaries = 1;									# Allow BBCODE on commentaries (0 = No, 1 = Yes)
our $config_commentsMaxLenght = 2000;									# Comment maximum characters
our $config_commentsRequireRegistration = 1;							# 1st Comment is mailed to admin for evaluation (0 = No, 1 = Yes)
our $config_commentsSecurityCode = 1;									# Allow security code for comments (0 = No, 1 = Yes)
our @config_commentsForbiddenAuthors = qw/admin administrator/;# usernames that normal users cant use, will ask for password
our $config_commentsDescending = 0;										# order of comments (0 = newest first, 1 = oldest first)
our $config_searchMinLength = 4;													# Minimum length of search keywords - avoids words like "or", "a", etc
our $config_socialAllowed = 1;														# Allow the social links
our $config_redditAllowed = 1;														# Allow the reddit option, to share your posts (0 = No, 1 = Yes)
# see https://about.twitter.com/resources/buttons
our $config_twitterAllowed = 1;														# Allow the twitter option, to share your posts (0 = No, 1 = Yes)
# see https://developers.facebook.com/docs/plugins/share-button
our $config_facebookAllowed = 1;													# Allow the facebook option, to share your posts (0 = No, 1 = Yes)
our $config_facebookSite = "http://blog.example.com";									# facebook sharing isn't that smart
# see https://developers.google.com/+/web/share/
our $config_googlePlusAllowed = 1;													# Allow the google+ option, to share your posts (0 = No, 1 = Yes)
our $config_menuEntriesLimit = 10;												# Limits of entries to show in the menu
our @config_menuLinks = ('http://example.com,Example Website'); # Links to be displayed at the menu
our $config_menuShowLinks = 1;													# Show links at the menu? (0 = No, 1 = Yes)
our $config_menuLinksHeader = 'Links';										# the header before the links appear (in the menu)
our $config_allowCustomHTML = 0;												# Want to add some code? (0 = No, 1 = Yes)
our $config_customHTML = '';														# your HTML here (any HTML you want)
our $config_showHits = 1;																# show total visits to your blog (0 = No, 1 = Yes)
our $config_showMap = 0;																# show map of visitor locations (0 = No, 1 = Yes)
our $config_dbSize = 500;																# in kB, if not using the map you can lower this to as low as 5
our $config_sendMailWithNewComment = 0;								# Receive a mail on new comments (0 = No, 1 = Yes).. needs sendmail
our $config_sendMailWithNewCommentMail = 'admin@example.com'; 	# Email adress to send mail if allowed
our $config_webMasterEmail = 'admin@example.com'; 				# Email adress for webmaster
our $config_showUsersOnline = 1;													# show number of current users on your site? (0 = No, 1 = Yes)
our $config_usersOnlineTimeout = 120;										# How long is a user considered online? In seconds
our $config_gmt = +0;																		# Your GMT; -3 = Buenos Aires, +8 = syndey, australia
our $config_showLatestComments = 1;										# Show latest comments on the menu
our $config_showLatestCommentsLimit = 10;							# Show 10 latest comments
our $config_allowBBcodeButtonsOnComments = 1;				# Allow BBCODE Buttons on Comments Form
our $config_commentsPerPage = 20;											# How many comments will be shown per page
our $config_showGmtOnFooter = 1;												# Display GMT on footer
our $config_securityQuestionOnComments = 1;						# use a security question when users post comments
our $config_commentsSecurityQuestion = 'The capital of Australia?';	# You shall change it, choose a question all your users will know
our $config_commentsSecurityAnswer = 'Canberra';					# Answer of the security question. CaSe InSeNsItIvE!
our $config_randomString = 'zjhd092nmbd20dbJASDK1BFGAB1';	# This is for password encryption... Edit if you want
our $config_entriesOnRSS = 0;														# 0 = ALL ENTRIES, if you want a limit, change this
our $config_useHtmlOnEntries = 0;												# Allow HTML when making a new post (THIS WILL DISALLOW BBCODE!!)
our $config_useWYSIWYG = 0;															# Requires HTML on entries (above) to work.. this wont allow smilies
our $config_onlyNumbersOnCAPTCHA = 1;									# Use only numbers on CAPTCHA
our $config_CAPTCHALength = 8;													# Just to make different codes
our $config_licenceMessage = 'Licenced under CC BY-NC-SA 4.0 Licence.';			# licence message
our $config_licenceMessageExtra = '';											# optional extra licence message
our $config_licenceImage = '<a href="http://creativecommons.org/licenses/by-nc-sa/4.0/" title="CC Licence">
<img style="height:24" src="'.$config_imgFilesFolder.'/by-nc-sa.png" alt="CC-BY-SA logo" /></a>';		# optional licence logo(s) possibly with links
#
return 1;
# End Of Main PPLOG Configuration, if you dont know what you are doing, dont touch anything else please ^_^