/**
 * iox.flash
 *
 * copyright by TASTENWERK
 *
 * (c) 2013
 *
 * dependencies:
 *
 * iox.core
 * jquery.centerjs
 *
 */

( function(){

  'use strict';

  window.iox.flash = window.iox.flash || flash;
  window.iox.flash.defaults = {

    // default dom element to attach
    obj: '.iox-flash-container'

  }

  function flash( _options ){

    // setup default options and override
    // with passed in options
    var options = window.iox.flash.defaults;
    for( var i in _options )
      options[i] = _options[i];

    if( !options.message )
      return;

    var $flash = $('<span/>').addClass('flash-item notice')
      .html(  options.message + ' &nbsp; <span style="opacity: 0.3">(' + moment().format('HH:mm:ss')+')</span>' );

    if( options.type === 'alert' )
      $flash.addClass('alert').removeClass('notice');

    $( options.obj ).fadeOut( 200, function(){
      $(options.obj).html( $flash );
      $(options.obj).fadeIn( 500 );
    });

  }

  flash.rails = function flashRails( msg_obj ){
    msg_obj.forEach( function( msg ){
      flash({ type: msg[0], message: msg[1] });
    });
  }

  flash.notice = function flashNotice( msg ){
    flash( { type: 'notice', message: msg } );
  }

  flash.alert = function flashAlert( msg ){
    flash( { type: 'alert', message: msg } );
  }


})();
