/**
 * ion.flash
 *
 * copyright by TASTENWERK
 *
 * (c) 2013
 *
 * dependencies:
 *
 * ion.core
 * jquery.centerjs
 *
 */

( function(){

  'use strict';

  window.ion.flash = window.ion.flash || flash;
  window.ion.flash.defaults = {

    // default dom element to attach
    obj: '.ion-flash-container'

  }

  function flash( _options ){

    // setup default options and override
    // with passed in options
    var options = window.ion.flash.defaults;
    for( var i in _options )
      options[i] = _options[i];

    if( !options.message )
      return;

    var $flash = $('<span/>').addClass('flash-item notice')
      .html( options.message );

    if( options.type === 'alert' )
      $flash.addClass('alert').removeClass('notice');

    $(options.obj).html( $flash )

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
