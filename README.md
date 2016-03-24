## sjpplog_ng

This is based on the original [sjpplog](http://pplog.scottjarvis.com/)
which is in turn based on Fedukun's [pplog](https://code.google.com/archive/p/pplog/),
a single `perl` script that controls an entire blog! No need for SQL data bases
as all data is kept in flat files.

### So what is different? 

 - _multiuser_ capability: the blog can have multiple posters
 - beefed up security
 - extra features such as extra sharing options and a new "hit" map by @jamesbond3142;
 see [here](http://www.lightofdawn.org/blog/?viewDetailed=00030)
 - other bugfixes and enhancements
 
### So who is using it?

 - [Puppy Linux blog](http://blog.puppylinux.com)
 
---

#### Deployment

On shared hosting (apache, nginx), you should put `blog/cgi-bin/` and 
`blog/www` under your `/home/user/public_html` (or wherever your websites 
normally go) directory and point your domain to `/home/user/public_html/blog`. 
Rename `blog` to whatever you want if you wish. Rename `example.htaccess`
to `.htaccess` and edit it if you know what you are doing. Preferably, if 
you have access to the apache/nginx config you should edit this instead of
using an `.htaccess` file but this isn't always possible.

Then, you **must** put `external` above `/public_html` for security reasons.
It must be a writable location. You can rename `external` if you wish.

To configure, open `cgi-bin/pup_pplog.conf.pl` in a text editor and edit 
the following:

 - `our $config_blogTitle = 'The Blog';` # Blog title with yours
 - `our $config_adminPass = 'Password1';`	# Admin password to get started, but you are prompted to change it later
 - `our $config_blogStart = 'Mar 2016';`  # date the blog commenced - optional
 - `our $config_wwwFolder = '/my/path/on/server/puppyblog/external/blog';` #for your writeable stuff
 - other stuff below that suits your needs
 
In Puppy Linux you can just put the lot int `/root/Web-Server`.

I'm sure if you have your own server or VPS you will be able to figure it out. :smile:

---

**More to come**
