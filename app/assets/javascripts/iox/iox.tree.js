/**
 * ionTable (jQuery plugin using knockoutjs)
 *
 * written by thorsten zerha
 * (c) by TASTENWERK http://tastenwerk.com
 *
 * this plugin is free to use for open-source or commercial work
 *
 */

(function(){

  'use strict';

  if( window.iox && window.iox.Tree )
    return;

  window.iox = window.iox || {};

  window.iox.Tree = window.iox.Tree || {};

  window.iox.Tree.defaults = {
    template: 'iox-tree-item-template',

    // the to be used, when creating a new obbject
    // if null, no object creation is initialized
    creationURL: null,

    // the url to be used when deleting object
    // defaults to url with type: 'delete'
    deletionURL: null,

    // reorder URL can include {:id} which will be replaced
    // with element's id
    reorderURL: null,

    // additional properties to observe
    // in an array
    observe: [],

    // additional events which are bound to the
    // tree item. They can be called from the
    // knockoutjs template
    // item will be attached to a tree item
    // tree will be attached to the tree itself
    //
    events: { item: [], tree: [] },

    // control div
    // where find, create and refresh buttons are
    // located
    // default: null
    control: null,

    searchTimeout: 200,

    i18n: {
      noEntriesFound: 'No entries were found (clear query above to reset)'
    }

  };

  $.fn.ioxTree = function ioxTree( options ){

    if( typeof(arguments[0]) === 'string' )
      return dispatchFunctions.apply( $(this).data('ioxTree'), arguments );

    if( !$(this).get(0) || $(this).get(0).nodeName !== 'UL' )
      throw new Error('[iox.tree] dom elemen not found. must be a <ul> element');

    var tree = new Tree( this, options );
    tree.init();
    tree.loadData( null, tree.render );
    if( tree.options.control && $(tree.options.control).length === 1 )
      tree.setupControlEvents();

  };

  function dispatchFunctions( cmd ){
    switch( cmd ){
      case 'append': {
        if( arguments[2] ){
          var $parent = $(this.obj).find('#item_'+arguments[2]);
          if( $parent.length ){
            if( $parent.find('.open-folder.open').length ){
              var parent = ko.dataFor( $parent.get(0) );
              parent.children.push( new TreeItem( arguments[1], this ) );
            } else{
              $parent.find('.open-folder').click();
            }
          } else
            throw Error('parent not found');
        } else{
          this.items.push( new TreeItem( arguments[1], this ) );
        }
        break;
      }
    }
  }

  function Tree( obj, options ){

    this.obj = obj;
    this.options = options || {};
    for( var i in window.iox.Tree.defaults )
      if( !(i in this.options) )
        this.options[i] = iox.Tree.defaults[i];

    this.items = ko.observableArray([]);

    if( this.options.events ){
      if( this.options.events.tree )
        for( var i in this.options.events.tree )
          this[i] = this.options.events.tree[i];
    }

  }

  /**
   * initializes and sets up basic
   * html elements
   */
  Tree.prototype.init = function init(){
    $(this.obj).attr('data-bind', 'template: { name: "'+this.options.template+'", foreach: items}')
      .addClass('iox-tree');
  }

  /**
   * load data from given url
   *
   * expecting a json
   */
  Tree.prototype.loadData = function loadData( parent, query, callback ){
    var self = this;
    if( typeof(query) === 'function' && typeof(callback) === 'undefined' ){
      callback = query;
      query = '';
    }
    self.items.removeAll();
    $(self.obj).find('li').remove();
    if( !parent )
      $.getJSON( this.options.url+'?parent=&query='+query, function( json ){
        if( !json.items )
          throw Error('[iox.tree] expected object key "items" in json response');
        for( var i=0,item; item=json.items[i]; i++ )
          self.items.push( new TreeItem( item, self ) );
        callback.call( self );
      });
  }

  /**
   * render the tree to the document
   */
  Tree.prototype.render = function render(){
    ko.cleanNode( $(this.obj).get(0) );
    $(this.obj).html('');
    ko.applyBindings( this, $(this.obj).get(0) );
    this.setupEventListeners();
    $(this.obj).data('ioxTree', this);
  }

  /**
   * setup tree control events
   */
  Tree.prototype.setupControlEvents = function setupControlEvents(){

    var self = this;
    var $control = $(this.options.control);

    if( $(self.obj).hasClass('control-setup-done') )
      return;

    $(self.obj).addClass('control-setup-done');


    var $refreshBtn = $control.find('[data-tree-role=refresh]')
    if( $refreshBtn.length )
      $refreshBtn.off('click').on('click', function(e){
        e.preventDefault();
        self.loadData( null, self.render );
      });

    var $searchBtn = $control.find('[data-tree-role=search]')
    if( $searchBtn.length ){
      $searchBtn.off('click').on('click', function(e){
        e.preventDefault();
        $(this).closest('form').addClass('search-active')
          .find('input[type=text]').select();
      });
      $(document).on('click', function(e){
        if( $(e.target).closest('.iox-tree-control').length || $('.iox-tree-control input[type=text]').val().length > 0 )
          return;
        $('.iox-tree-control form').removeClass('search-active');
      }).on('keydown', function(e){
        if( e.keyCode === 27 ){
          $('.iox-tree-control input[type=text]').val('');
          $('.iox-tree-control form').removeClass('search-active').submit();
        }
      })
    }

    var $newBtn = $control.find('[data-tree-role=new]');
    if( $newBtn.length )
      $newBtn.off('click').on('click', function(e){ e.preventDefault(); self.newItemForm.apply( this, [ e, self, TreeItem ] ) });

    var $queryField = $control.find('input[name=query]')
    if( $queryField.length ){
      var continueSearchFilter;
      var lastSearchTriggered;
      $queryField.attr('autocomplete','off').off('keyup').on('keyup', function(e){
        var val = $(this).val();
        continueSearchFilter = $(this).val();
        setTimeout( function(){
          if( continueSearchFilter != val )
            return;
          e.preventDefault();
          if( lastSearchTriggered != val )
            self.filterItems( val .toLowerCase() );
          lastSearchTriggered = val;
        }, self.options.searchTimeout );
      });
      $queryField.closest('form').off('submit').on('submit', function(e){
        e.preventDefault();
        self.filterItems( $(this).find('input[type=text]').val().toLowerCase() );
      });
    }
  }

  Tree.prototype.filterItems = function filerItems( filter, items ){
    var self = this;
    var $control = $(this.options.control);
    this.loadData( null, filter, function(){
      self.render( self );
      if( $(self.obj).find('.item:visible').length < 1 ){
        if( !$control.next('.iox-no-entries-found').length )
          $control.after('<div class="iox-no-entries-found">'+self.options.i18n.noEntriesFound+'</div>');
      } else
        $control.next('.iox-no-entries-found').remove();
    });

    // changed behavior to server side response as only
    // this can consider any item
    //
    /*
    var self = this;
    items = items || self.items();
    ko.utils.arrayForEach(items, function(item) {
      var name = item[ self.options.queryFieldName || 'name' ];
      name = ( typeof(name) === 'function' ? name() : name );
      if( filter === '' || name.toLowerCase().indexOf(filter) >= 0 ){
        item._hide( false );
      }
      else{
        item._hide( true );
      }
      if( item.children() && item.children().length > 0 )
        self.filterItems( filter, item.children() );
    });
    */
  }

  /**
   * setup Tree event listeners
   */
  Tree.prototype.setupEventListeners = function setupEventListeners(){
    var self = this;

    if( $(self.obj).hasClass('ui-sortable') )
      $(self.obj).nestedSortable('destroy');

    $(self.obj).nestedSortable({
      handle: 'div',
      listType: 'ul',
      items: 'li',
      delay: 300,
      toleranceElement: '> div',
      update: function( e, ui ){
        var order = [];
        $(e.target).closest('ul').find('li').each( function(){
          order.push( $(this).attr('id') );
        });
        var item = ko.dataFor($(ui.item).get(0));
        $.ajax({ url: (self.options.reorderURL ? self.options.reorderURL.replace('{:id}',item.id) : self.options.url+'/'+item.id+'/reorder'),
          type: 'post',
          dataType: 'json',
          data: {
            order: order,
            parent: ( $(ui.item).parent().closest('li').length ? $(ui.item).parent().closest('li').attr('data-id') : null )
          }
        }).done( function( json ){
          if( window.iox )
            iox.flash.rails( json.flash );
        });
      }
    });
    $(self.obj).disableSelection();
  }

  /* -------------------------------------------------------------- */
  /**
   * TreeItem
   * one li item
   */
  function TreeItem( item, master ){
    this._master = master;
    this.children = ko.observableArray();
    this._hide = ko.observable(false);
    this._selected = ko.observable(false);
    this._parent = ko.observable();
    for( var i in item )
      if( i.match(/name|position/) || ( this._master.options.observe && this._master.options.observe.indexOf(i) >= 0 ) )
        this[i] = ko.observable( item[i] );
      else
        this[i] = item[i];

    /**
     * compute the number of children
     */
    this.hasChildren = ko.computed(function() {
      return ( this.num_children > 0 || this.children.length > 0 );
    }, this);

    if( this._master.options.events ){
      if( this._master.options.events.item )
        for( var i in this._master.options.events.item )
          this[i] = this._master.options.events.item[i];
    }

  }

  /**
   * remove an item
   *
   */
  TreeItem.prototype.removeItem = function removeItem( item, e ){
    var text = $(e.target).attr('data-confirm-proceed') || ( $(e.target).closest('[data-confirm-proceed]') && $(e.target).closest('[data-confirm-proceed]').attr('data-confirm-proceed') );
    if( text ){
      if( !confirm( text ) ){
        e.preventDefault();
        return false;
      }
    }

    var url = (item._master.options.deletionURL || item._master.options.url)+'/'+item.id;
    $.ajax({ url: url, type: 'delete', dataType: 'json' }).done( function( response ){
      if( response.success ){
        item._master._selectedItem = null;
        var $parent = $(item._master.obj).find('[data-id='+item.id+']').parent().closest('li');
        if( $parent.length ){
          var parent = ko.dataFor( $parent.get(0) );
          parent.children.remove( item );
        } else{
          item._master.items.remove( item );
        }
      }
      if( iox )
        iox.flash.rails( response.flash );
      if( item._master.options.events && typeof(item._master.options.events.afterRemove) === 'function' )
        item._master.options.events.afterRemove( item );

    });
  }

  /**
   * open and show node's children
   *
   */
  TreeItem.prototype.showChildren = function showChildren( item, e ){
    if( !$(e.target).hasClass('open-folder') )
      return;
    var self = this;
    if( $(e.target).hasClass('open') )
      return $(e.target).removeClass('icon-angle-down').removeClass('open').addClass('icon-angle-right').removeClass('open').closest('li').find('ul').slideUp(200);
    if( $(e.target).closest('li').find('ul li').length )
      return $(e.target).removeClass('icon-angle-right').addClass('icon-angle-down open').closest('li').find('ul').slideDown(200);
    $.getJSON( self._master.options.url+'?parent='+item.id ).done( function( json ){
      if( json.items && json.items.length > 0 ){
        for( var i=0,child;child=json.items[i];i++ )
          item.children.push( new TreeItem( child, self._master ) );
        $(e.target).removeClass('icon-angle-right').addClass('icon-angle-down open').closest('li').find('ul').slideDown(200);
        self._master.setupEventListeners();
      }
    });
  }

  /**
   * highlight and mark this item
   */
  TreeItem.prototype.markItem = function markItem( item, e ){

    if( e )
      e.stopPropagation();
    if( item._selected() ){
      item._selected( false );
      item._master._selectedItem = null;
      return;
    }
    item.showForm( item, e );
    item._selected( true );
    if( item._master._selectedItem )
        item._master._selectedItem._selected( false );
    item._master._selectedItem = item;
  }

  /**
   * add a new item below
   */
  TreeItem.prototype.newItemBelow = function newItemBelow( item, e ){
    if( !this._master.options.creationURL )
      return;
    $.getScript( this._master.options.creationURL+'?parent='+item.id );
  }

})();
