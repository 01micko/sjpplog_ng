/*   - javascript functions from stackoverflow.com and thesitewizard.com
 *   - mixed togther for PPLOG 1.2a, march, 2001
 *   - created by sc0ttman, GPL, etc
 */ 

// options to customise here
var style_cookie_name = "userStyle" ;
var style_cookie_duration = 3 ;
var show_alert = false ; // should be false, set to true for testing only!
// "sheet" is the var which actually holds the chosen css stylesheet

// usage: set_cookie( "userStyle", "style1.css", 7, "domain.com" );
function set_cookie ( cookie_name, cookie_value, lifespan_in_days, valid_domain ){
	var domain_string = valid_domain ?
			("; domain=" + valid_domain) : '' ;
	document.cookie = cookie_name +
			"=" + encodeURIComponent( cookie_value ) +
			"; max-age=" + 60 * 60 *
			24 * lifespan_in_days +
			"; path=/" + domain_string ;
}
// usage:  var style = get_cookie( "userStyle" );
function get_cookie ( cookie_name ){
    var cookie_string = document.cookie ;
    if (cookie_string.length != 0) {
        var cookie_value = cookie_string.match (
			'(^|;)[\s]*' +
			cookie_name +
			'=([^;]*)' );
        return decodeURIComponent ( cookie_value[2] ) ;
    }
    return '' ;
}
// usage: onLoad="JavaScript:set_style_from_cookie();"
function set_style_from_cookie(){
  var sheet = get_cookie( style_cookie_name );
  if (sheet.length) {
	changeStyle (sheet);
  }
}
// usage: onClick="JavaScript:changeStyle('style1.css');"
function changeStyle(sheet) {
	// add time to stylesheet, so all stylings are refreshed in browser
	var date = new Date().getTime();
	// overwrite main style 
	document.getElementById('mainStyle').href = sheet + '?' + date;
	// alert user
	if ( show_alert ) { alert( "Style changed to " + sheet + '?' + date ) };
	// write style to cookie, so selected style can be set with onload="set_style_from_cookie();"
	set_cookie( style_cookie_name, sheet, style_cookie_duration );
}
