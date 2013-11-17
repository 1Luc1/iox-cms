//= require 3rdparty/password-generator.min
//= require 3rdparty/jquery.fileupload

$(function(){

  window.iox = window.iox || {};
  window.iox.webpageTmpl = window.iox.webpageTmpl || {};

  if( $('.webpage-profile').length ){

    $('.webpage-upload-avatar').fileupload({
      dataType: 'json',
      formData: {
        "authenticity_token": $('input[name="authenticity_token"]:first').val()
      },
      done: function (e, data) {
        var avatar = data._response.result[0];
        $('.avatar-thumb[data-webpage-id='+avatar.id+']').attr('src', avatar.thumbnail_url);
        $('.avatar[data-webpage-id='+avatar.id+']').attr('src', avatar.url);
      }
    });

  }

  window.iox.webbits = window.iox.webbits || {};

  function setupTreeSource( webpage_id ){
    return new kendo.data.HierarchicalDataSource({
      transport: {
        read: function( options ){
          $.ajax({
            url: '/iox/webpages/'+webpage_id+'/webbits?parent_id='+(options.data.id ? options.data.id : '')+'&locale='+kendo.culture(),
            dataType: 'json',
            type: 'get'
          }).done( function( json ){
            options.success( json );
          });
        },
        update: function( options ){
          options.success();
        },
        destroy: function( options ){
          options.success();
        }
      },
      schema: {
          model: {
              id: 'id',
              hasChildren: 'has_children'
          }
      }
    });
  }

  window.iox.webbits.setupGrid = function( $elem, item ){

    var treeSource = setupTreeSource( webpage_id );
    var treeview;

    var kGrid = $elem.kendoGrid({
              dataSource: {
                  type: "json",
                  transport: {
                    read: '/iox/webpages/'+item.id+'/webbits'
                  },
                  schema: {
                    model: {
                      fields: {
                        id: { type: "number" },
                        email: { type: "string" },
                        phone: { type: "string" },
                        text: { type: "string" },
                        created_at: { type: 'date' }
                      }
                    }
                  },
                  pageSize: 20,
                  serverPaging: false,
                  serverFiltering: false,
                  serverSorting: false
              },
              height: $('#iox-content-details').height()-100,
              filterable: false,
              sortable: true,
              pageable: false,
              columns: [
                { field: 'email' },
                { field: 'phone' },
                { field: 'text' },
                { field: 'created_at',
                  width: 160,
                  format: '{0:dd.MM.yyyy HH:mm}' },
                { width: 40,
                  command:
                  [
                    { name: 'removeAnswer',
                      text: '<i class="icon-trash"></i>',
                      click: function(e){
                        var dataItem = this.dataItem($(e.currentTarget).closest("tr"));
                        if( confirm('Die Antwort der Email Adresse '+dataItem.email+' löschen und Benutzer damit wieder für neue Antwort freigeben?')){
                          $.ajax({
                            url: '/iox/tsp_gamble_answers/'+dataItem.id,
                            type: 'delete'
                          }).done( function(response){
                            iox.flash.rails(response.flash);
                            if( response.success )
                              kGrid.data('kendoGrid').removeRow( $(e.target).closest('tr') );
                          });
                        }
                      }
                    }
                  ]
                }
              ]
          });

    treeview = $elem.data('kendoTreeView');

    $elem.on('click', '.k-item', function(e){
      e.stopPropagation();
      var wasSelected = $(this).hasClass('selected').length > 0;
      $elem.find('li').removeClass('selected').find('.k-in').removeClass('k-state-selected');
      if( !wasSelected ){
        $(this).addClass('selected');
        $(this).find('.k-in:first').addClass('k-state-selected')
      }
      $('.webbit').removeClass('active');
      $('#wb_'+$(this).find('[data-webbit-id]').attr('data-webbit-id')).addClass('active');

      iox.webbits.showForm( $(this), treeview );

    });

  }

  window.iox.webbits.showForm = function showForm( $elem, treeview ){
    kendo.bind( $elem.find('.webbit-form').get(0), treeview.dataItem( $elem ) );
  }

});