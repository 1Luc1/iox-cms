//= require jquery
//= require jquery_ujs

//= require 3rdparty/jquery.center
//= require 3rdparty/jquery-ui-1.10.3.custom
//= require 3rdparty/jquery.nested-sortable.min
//= require 3rdparty/bootstrap
//= require 3rdparty/knockout
//= require 3rdparty/jquery.blockui

//= require 3rdparty/kendoui/kendo.web.min

//= require iox/iox.core
//= require iox/iox.flash
//= require iox/iox.tree
//= require iox/iox.win


//= require_self

$(function(){

  $('.iox-auth-win input[type=text]:first').focus();

  $('.js-get-focus:first').focus();

  $('.iox-app-nav a').tooltip({
    placement: 'right'
  });
  $('[rel=tooltip]').tooltip({
    placement: 'bottom'
  });

  $.blockUI.defaults.css = {};
  $.blockUI.defaults.overlayCSS = {};
  $.blockUI.defaults.message = iox.loader;

  $('.iox-mcc').css( 'height', ( $(window).height() - $('.iox-top-nav').height() - 1 ) );
  if( $('.iox-sidebar').length ){
    $('.iox-sidebar-arrow').css('top', $('.iox-app-nav li.active').offset().top+12);
  }

  // data-xhr-url indicates a snippet to be loaded
  // into it's container
  $('[data-xhr-url]').each( function(e){

    $(this).block({
      message: iox.loaderHorizontal+'<span>'+($(this).attr('data-xhr-wait-txt') || '')+'</span>'
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

    var $loader = $('<div>'+iox.loaderHorizontal+'</div>')
      .find('.iox-loader-horizontal')
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
      new iox.Win({ content: htmlRes });
    });
  });

});