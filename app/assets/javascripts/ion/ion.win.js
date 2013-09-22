/**
 * ion.win
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

  window.ion.Win = window.ion.Win || Win;
  window.ion.Win.defaults = {

    // title of the window (shown on the top)
    // false: no title is shown
    // default: 'parse' from given html response
    title: 'parse',

    // close button
    // default: '<i class="icon-close"></i>'
    closeIcon: '<i class="icon-remove"></i>',

    // where to append the win
    appendTo: 'body',

    // if header should be rendered
    // default: true
    renderHeader: true,

    // renders a sidebar according to the
    // given elements in the content
    // default: false
    renderSidebar: false,

    // content. The html content object
    content: '',

    // height of the window
    height: null,

    // width of the window
    width: null

  }

  window.ion.Win.closeAll = function closeAllWin(){
    $('.ion-win').each( function(){
      $(this).find('[data-close-win]:first').click();
    });
  }

  function checkCloseWin(e){
    if( $(e.target).closest('.ion-win').length )
      return;
    $(e.target).closest('.ion-win').find('[data-close-win]:first').click();
  }

  function closeWinEvent(e){
    e.preventDefault();
    $(this).closest('.ion-win').remove();
    $(document).off('click', checkCloseWin);
    $('.ion-win-overlay:last').remove();
  }

  function Win( _options ){

    // setup default options and override
    // with passed in options
    this.options = window.ion.Win.defaults;
    for( var i in _options )
      this.options[i] = _options[i];

    this.options.content = $('<div>'+this.options.content+'</div>');

    var $win = $('<div/>')
      .addClass('ion-win');

    if( this.options.renderHeader )
      $win.append( this.renderHeader() );

    $win.append( $('<div class="body"/>').html( this.options.content.html() ) );

    if( this.options.height )
      $win.css('height', this.options.height);

    if( this.options.width )
      $win.css('width', this.options.width);

    var $overlay = $('<div/>')
      .addClass('ion-win-overlay');
    $(this.options.appendTo).append( $overlay );
    $overlay.css('height', window.innerHeight );

    $(this.options.appendTo).append( $win );

    $win.center();
    $win.find('[data-close-win]').on('click', closeWinEvent );
    $win.find('.js-get-focus').focus();
    $(document).on('click', checkCloseWin);

  }


  /**
   * renders a header if renderHeader option
   * is not set to false
   */
  Win.prototype.renderHeader = function renderHeader(){

    var $header = null;

    var $closeBtn = $('<button/>')
      .addClass('close-btn')
      .attr('data-close-win', true)
      .append( this.options.closeIcon )
    $header = $('<div/>')
      .addClass('ion-win-header')
      .append( $closeBtn );
    if( this.options.title ){

      var $title = $('<span/>')
        .addClass('ion-win-title')
        .text( this.options.title )

      if( this.options.title === 'parse' )
        $title = $(this.options.content).find('[data-ion-win-title]:first').remove().addClass('ion-win-title');

      $header.append( $title );
    }

    return $header;

  }

  /**
   * renders a sidebar if renderSidebar options
   * is not set to false
   *
   */
  Win.prototype.renderSidebar = function renderSidebar(){

    var $sidebar = '';

    return $sidebar;

  }

})();
