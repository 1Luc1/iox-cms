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

  if( window.Ion && window.Ion.Tree )
    return;

  window.Ion = window.Ion || {};

  window.Ion.Tree = window.Ion.Tree || {};

  window.Ion.Tree.defaults = {
    template: 'ion-tree-item-template',

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
    control: null

  };

  $.fn.ionTree = function ionTree( options ){

    if( typeof(arguments[0]) === 'string' )
      return dispatchFunctions.apply( $(this).data('ionTree'), arguments );

    if( $(this).get(0).nodeName !== 'UL' )
      throw new Error('[ion.tree] object must be a <ul> element');

    var tree = new Tree( this, options );
    tree.init();
    tree.loadData( null, tree.render );

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
    for( var i in window.Ion.Tree.defaults )
      if( !(i in this.options) )
        this.options[i] = Ion.Tree.defaults[i];

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
      .addClass('ion-tree');
  }

  /**
   * load data from given url
   *
   * expecting a json
   */
  Tree.prototype.loadData = function loadData( parent, callback ){
    var self = this;
    self.items.removeAll();
    if( !parent )
      $.getJSON( this.options.url+'?parent=', function( json ){
        if( !json.items )
          throw Error('[ion.tree] expected object key "items" in json response');
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
    $(this.obj).data('ionTree', this);
    if( this.options.control && $(this.options.control).length === 1 )
      this.setupControlEvents();
  }

  /**
   * setup tree control events
   */
  Tree.prototype.setupControlEvents = function setupControlEvents(){
    var self = this;
    var $control = $(this.options.control);
    var $refreshBtn = $control.find('[data-tree-role=refresh]')
    if( $refreshBtn.length )
      $refreshBtn.off('click').on('click', function(e){
        e.preventDefault();
        self.loadData( null, self.render );
      });
    var $newBtn = $control.find('[data-tree-role=new]')
    if( $newBtn.length )
      $newBtn.off('click').on('click', function(e){ e.preventDefault(); self.newItemForm.apply( this, [ e, self, TreeItem ] ) });
    var $queryField = $control.find('input[name=query]')
    if( $queryField.length )
      $queryField.attr('autocomplete','off').off('keyup').on('keyup', function(e){
        e.preventDefault();
        self.filterItems( $(this).val().toLowerCase() );
      });
  }

  Tree.prototype.filterItems = function filerItems( filter ){
    var self = this;
    ko.utils.arrayForEach(self.items(), function(item) {
      var name = item[ self.options.queryFieldName || 'name' ];
      name = ( typeof(name) === 'function' ? name() : name );
      if( filter === '' || name.toLowerCase().indexOf(filter) >= 0 ){
        item._hide( false );
        if( item.children() && item.children().length > 0 )
          self.filterItems( filter );
      }
      else{
        item._hide( true );
      }
    });
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
        }).done( function( response ){
          if( ion )
            ion.flash( response.flash );
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
    var self = this
      , url = (this._master.options.deletionURL || this._master.options.url)+'/'+item.id;
    $.ajax({ url: url, type: 'delete', dataType: 'json' }).done( function( response ){
      if( response.success )
        self._master.items.remove(item);
      ion.flash( response.flash );
    });
  }

  /**
   * open and show node's children
   *
   */
  TreeItem.prototype.showChildren = function showChildren( item, e ){
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
   * add a new item below
   */
  TreeItem.prototype.newItemBelow = function newItemBelow( item, e ){
    if( !this._master.options.creationURL )
      return;
    $.getScript( this._master.options.creationURL+'?parent='+item.id );
  }

})();
