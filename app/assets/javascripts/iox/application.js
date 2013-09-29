//= require jquery
//= require jquery_ujs
//= require select2

//= require 3rdparty/jquery.center
//= require 3rdparty/jquery-ui-1.10.3.custom
//= require 3rdparty/jquery.nested-sortable.min
//= require 3rdparty/bootstrap
//= require 3rdparty/knockout
//= require 3rdparty/moment-2.0.0.min
//= require 3rdparty/moment.lang.de
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

/*
  $('body').tooltip({
    selector: '[rel=tooltip]',
    placement: function(tip, element){
      // DOES NOT WORK:
      var position = $(element).position();
      if (position.left > 515) {
          return "left";
      }
      if (position.left < 515) {
          return "right";
      }
      return "bottom";
  }
  });
*/

  $.blockUI.defaults.css = {};
  $.blockUI.defaults.overlayCSS = {};
  $.blockUI.defaults.message = iox.loader;

  $('.iox-mcc').css( 'height', ( $(window).height() - $('.iox-top-nav').height() - 1 ) );
  if( $('.iox-sidebar-arrow').length && $('.iox-app-nav li.active a').length ){
    $('.iox-sidebar-arrow').css('top', $('.iox-app-nav li.active a').offset().top-40);
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
      var options = { content: htmlRes };
      if( $(self).attr('data-xhr-win-title') )
        options.title = $(self).attr('data-xhr-win-title');
      new iox.Win( options );
    });
  });

  $('body').on('click', '.iox-simple-select-trigger', function(e){
    e.preventDefault();
    $(this).closest('.iox-simple-select').find('.iox-simple-select-list').slideToggle(100);
    $(this).closest('.iox-simple-select').toggleClass('toggled');
  })

  $(document).on('click', '[data-confirmation-win]', function(e){
    e.preventDefault();
    new iox.Win({ content: '<div class="content-padding">'+$(this).attr('data-confirmation-txt')+'</div><div class="iox-win-footer"><button class="btn" data-close-win="true">'+iox.Win.defaults.i18n.ok+'</button></div>' });
  });

  $('body').on('click', '[data-role=submit]', function(e){
    e.preventDefault();
    $(this).closest('.iox-content-padding').find('form:first').submit();
  });

  $('body').on('submit', '[data-role=submitAndBack]', function(e){
    if( $(this).closest('.iox-content-padding').find('[data-role=switch2content]').length )
      $(this).closest('.iox-content-padding').find('[data-role=switch2content]').click();
  });

  $('body').on('click', '[data-role=switch2content]', function(e){
    var $prevContainer = $(this).closest('.iox-details-container').prev('.iox-details-container');
    $(this).closest('.iox-details-container').remove();
    if( $prevContainer.length )
      $prevContainer.show();
    else
      $('.iox-content-container').show();
  });

  $(document).on('keyup', function(e){
    if( e.keyCode === 27 && $('.iox-win:visible').length )
      iox.Win.closeVisible();
  });

});