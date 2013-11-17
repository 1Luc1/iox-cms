/**
 * iox.core
 *
 * copyright by TASTENWERK
 *
 * (c) 2013
 *
 */

( function(){

  'use strict';

  window.iox = window.iox || {};
  window.iox.loader = "<div class=\"iox-loader\"></div>";
  window.iox.loaderHorizontal = "<div class=\"iox-loader-horizontal\"></div>";

  window.iox.preloadImage = function preloadImage( imgPath, callback ){
    $('<img/>').attr('src', imgPath).load( function(){
      $(this).remove();
      callback( imgPath );
    });
  }

  window.iox.validationHelper = {};
  window.iox.validationHelper.email = function validateEmail(email){
      var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return re.test(email);
  }

  window.iox.formatHelper = {};
  window.iox.formatHelper.Filesize = function formatFilesize( filesize, human ){
    // assuming filesize is comming as kb
    filesize = filesize * 1000;
    
    if (filesize >= 1073741824){
      var filesize = iox.formatHelper.FormatNumber(filesize / 1073741824, 3, '.', '');
      return ( human ? (filesize + ' Gb') : filesize );
    }
    if (filesize >= 1048576){
      var filesize = iox.formatHelper.FormatNumber(filesize / 1048576, 3, '.', '');
      return ( human ? (filesize + ' Mb') : filesize );
    }
    if (filesize >= 1024) {
      var filesize = iox.formatHelper.FormatNumber(filesize / 1024, 0);
      return ( human ? (filesize + ' Kb') : filesize );
    }
    var filesize = iox.formatHelper.FormatNumber(filesize, 0);
    return ( human ? (filesize + ' Bytes') : filesize );
  };

  window.iox.formatHelper.FormatNumber = function formatNumber( number, decimals, dec_point, thousands_sep ) {
    var n = number, c = isNaN(decimals = Math.abs(decimals)) ? 2 : decimals;
    var d = dec_point == undefined ? "," : dec_point;
    var t = thousands_sep == undefined ? "." : thousands_sep, s = n < 0 ? "-" : "";
    var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
     
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
  };

})();
