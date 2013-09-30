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

  window.iox.validationHelper = {};
  window.iox.validationHelper.email = function validateEmail(email){
      var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return re.test(email);
  }

})();
