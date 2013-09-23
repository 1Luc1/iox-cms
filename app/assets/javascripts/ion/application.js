//
//= require 3rdparty/jquery
//= require 3rdparty/jquery.center
//= require 3rdparty/bootstrap
//= require 3rdparty/knockout
//= require 3rdparty/jquery.blockui

//= require ion/ion.core
//= require ion/ion.flash
//= require ion/ion.tree
//= require ion/ion.win

//= require_self

$(function(){

  $('.ion-auth-win input[type=text]:first').focus();

  $('.js-get-focus:first').focus();

  $.blockUI.defaults.css = {};
  $.blockUI.defaults.overlayCSS = {};
  $.blockUI.defaults.message = ion.loader;

  $('.ion-mcc').css( 'height', ( $(window).height() - $('.ion-top-nav').height() ) );
  if( $('.ion-sidebar').length ){
    $('.ion-sidebar-arrow').css('top', $('.ion-app-nav li.active').offset().top+12);
  }

  // data-xhr-url indicates a snippet to be loaded
  // into it's container
  $('[data-xhr-url]').each( function(e){

    $(this).block({
      message: ion.loaderHorizontal+'<span>'+($(this).attr('data-xhr-wait-txt') || '')+'</span>'
    });
    var self = this;
    $.ajax({
      url: $(this).attr('data-xhr-url'),
      dataType: 'html',
      type: 'get'
    }).done( function( htmlRes ){
      $(self).unblock();
      $(self).html( htmlRes );
    });

  });

  // data-xhr-win makes clicking an element loading it's data-xhr-href or
  // href element
  $(document).on('click', '[data-xhr-win]', function(e){
    e.preventDefault();
    var self = this;
    var url = $(this).attr('data-xhr-href') || $(this).attr('href');
    if( !url )
      throw Error('no href nor data-xhr-href found');

    var $loader = $('<div>'+ion.loaderHorizontal+'</div>')
      .find('.ion-loader-horizontal')
        .attr('title', ($(this).attr('data-xhr-wait-title') || ''));

    $(this).block({
      message: $loader.html()+'<span>'+($(this).attr('data-xhr-wait-txt') || '')+'</span>'
    });

    $.ajax({
      url: url,
      dataType: 'html',
      type: 'get'
    }).done( function( htmlRes ){
      $(self).unblock();
      new ion.Win({ content: htmlRes });
    });
  });

});