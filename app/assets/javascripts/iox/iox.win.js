/**
 * iox.win
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

  window.iox.Win = window.iox.Win || Win;
  window.iox.Win.defaults = {

    // title of the window (shown on the top)
    // false: no title is shown
    // default: 'parse' from given html response
    title: 'parse',

    // close button
    // default: '<i class="icon-remove"></i>'
    closeIcon: '<i class="icon-remove"></i>',

    // save button
    // default: '<i class="icon-save"></i>'
    saveIcon: '<i class="icon-save"></i>',

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

    // ajax content to load
    // if you want to load the content from given url
    // default: null
    url: null,

    // height of the window
    height: null,

    // width of the window
    width: null,

    i18n: {
      ok: 'OK',
      yes: 'Yes',
      no: 'No'
    }

  }

  window.iox.Win.closeAll = function closeAllWin(){
    $('.iox-win').each( function(){
      $(this).find('[data-close-win]:first').click();
    });
  }

  window.iox.Win.closeVisible = function closeVisibleWin(){
    $('.iox-win:visible').each( function(){
      $(this).find('[data-close-win]:first').click();
    });
  }

  function checkCloseWin(e){
    if( $(e.target).closest('.iox-win').length )
      return;
    $(e.target).closest('.iox-win').find('[data-close-win]:first').click();
  }

  function closeWinEvent(e){
    e.preventDefault();
    $(this).closest('.iox-win').remove();
    $(document).off('click', checkCloseWin);
    $('.iox-win-overlay:last').remove();
  }

  function Win( _options ){

    var self = this;

    // setup default options and override
    // with passed in options
    this.options = window.iox.Win.defaults;
    for( var i in _options )
      this.options[i] = _options[i];

    if( this.options.yesNoQuestion ){
      this.options.content = '<div class="content-padding">'+this.options.yesNoQuestion+'</div><div class="iox-win-footer"><button class="btn btn-danger answer-no">'+this.options.i18n.no+'</button><button class="btn btn-success answer-yes pull-right" data-close-win="true">'+this.options.i18n.yes+'</button></div>';
    }

    if( this.options.url )
      return $.get( self.options.url, function( html ){
        self.options.content = html;
        self.options.url = null;
        new iox.Win( self.options );
      });
    if( !(this.options.content instanceof jQuery) )
      this.options.content = $('<div>'+this.options.content+'</div>');

    var $win = $('<div/>')
      .addClass('iox-win');

    if( this.options.renderHeader )
      $win.append( this.renderHeader() );

    $win.append( $('<div class="body"/>').html( this.options.content.html() ) );

    if( this.options.height )
      $win.css('height', this.options.height);

    if( this.options.width )
      $win.css('width', this.options.width);

    var $overlay = $('<div/>')
      .addClass('iox-win-overlay');
    $(this.options.appendTo).append( $overlay );
    $overlay.css('height', window.innerHeight );

    $overlay.on('click', function(e){
      $win.find('[data-close-win]').click();
    });

    $(this.options.appendTo).append( $win );

    $win.center();
    $win.find('[data-close-win]').on('click', closeWinEvent );
    $win.find('[data-save-win-form]').on('click', function(){
      $win.find('form:first').submit();
    });
    $win.find('.js-get-focus').focus();
    $(document).on('click', checkCloseWin);

    $win.find('form').on('submit', function(e){
      $win.block();
    });

    if( this.options.yesNoQuestion ){
      var self = this;
      $win.find('.answer-yes').on('click', function(e){
        $win.find('[data-close-win]:first').click();
        if( typeof(self.options.onYes) === 'function' )
          self.options.onYes( e );
      });
      $win.find('.answer-no').on('click', function(e){
        $win.find('[data-close-win]:first').click();
        if( typeof(self.options.onNo) === 'function' )
          self.options.onYes( e );
      });
    }
    if( this.options.completed && typeof(this.options.completed) === 'function' )
      this.options.completed( $win );

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
      .append( this.options.closeIcon );

    var $saveBtn = $('<button/>')
      .addClass('save-btn')
      .attr('data-save-win-form', true)
      .append( this.options.saveIcon );

    $header = $('<div/>')
      .addClass('iox-win-header')
      .append( $closeBtn );
    if( this.options.saveFormBtn )
      $header.append( $saveBtn );

    if( this.options.title ){

      var $title = $('<span/>')
        .addClass('iox-win-title')
        .text( this.options.title )

      if( this.options.title === 'parse' )
        $title = $(this.options.content).find('[data-iox-win-title]:first').remove().addClass('iox-win-title');

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
