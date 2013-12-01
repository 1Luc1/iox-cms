$( function(){

  window.iox.webfiles = {};

  window.iox.webfiles.setupGrid = function( $elem, item ){

    //var treeSource = setupTreeSource( item );
    var treeview;

    var kGrid = $elem.kendoGrid({
              dataSource: {
                  type: "json",
                  transport: {
                    read: '/iox/webpages/'+item.id+'/webfiles'
                  },
                  schema: {
                    model: {
                      fields: {
                        id: { type: "number" },
                        name: { type: "string" },
                        description: { type: "string" },
                        copyright: { type: "string" },
                        created_at: { type: 'date' },
                        content_type: { type: 'string' },
                        size: { type: 'integer' },
                        updater_name: { type: 'string' },
                        updated_at: { type: 'date' }
                      }
                    }
                  },
                  aggregate: [ { field: "size", aggregate: "sum" } ],
                  pageSize: 20,
                  serverPaging: false,
                  serverFiltering: false,
                  serverSorting: false
              },
              height: $(window).height()-220,
              filterable: false,
              sortable: true,
              pageable: false,
              columns: [
                { field: "thumb_url", 
                  title: I18n.t('webfile.preview'),
                  width: 30,
                  template: '<img src="#= thumb_url #" alt="image" />' },
                { field: 'name',
                  title: I18n.t('webfile.name')
                },
                { field: 'updater_name',
                  title: I18n.t('webfile.updated_by') },
                { field: 'updated_at',
                  width: 160,
                  title: I18n.t('webfile.updated_at'),
                  format: '{0:dd.MM.yyyy HH:mm}' },
                { field: 'content_type',
                  title: I18n.t('webfile.type') },
                { field: 'size',
                  width: 100,
                  footerTemplate: "#: iox.formatHelper.Filesize( sum, true ) #",
                  title: I18n.t('webfile.size')+' Kb'},
                { width: 120,
                  command:
                  [
                    { name: 'downloadFile',
                      text: '<i class="icon-download"></i>',
                      click: function(e){
                        var dataItem = this.dataItem($(e.currentTarget).closest("tr"));
                        window.open( dataItem.original_url )
                      }
                    },
                    { name: 'editFile',
                      text: '<i class="icon-edit"></i>',
                      click: function(e){
                        var dataItem = this.dataItem($(e.currentTarget).closest("tr"));
                        new iox.Win({
                          content: $('#edit-webfile-form-template').clone(),
                          completed: function( $win ){
                            ko.applyBindings({ 
                              item: dataItem, 
                              save: function saveWebfileForm( form ){
                                $win.find('[data-close-win]:first').click();
                                $.ajax({ 
                                  url: '/iox/webfiles/'+ dataItem.id,
                                  data: $(form).serializeArray(),
                                  dataType: 'json',
                                  type: 'patch'
                                }).done( function( response ){
                                  iox.flash.rails( response.flash );
                                  if( response.success )
                                    kGrid.data('kendoGrid').dataSource.read();
                                });
                              }
                            }, $win.get(0) );
                          }
                        });
                      }
                    },
                    { name: 'removeFile',
                      text: '<i class="icon-trash-o"></i>',
                      click: function(e){
                        var dataItem = this.dataItem($(e.currentTarget).closest("tr"));
                        $.ajax({
                          url: '/iox/webfiles/'+dataItem.id,
                          type: 'delete'
                        }).done( function(response){
                          iox.flash.rails(response.flash);
                          if( response.success )
                            kGrid.data('kendoGrid').removeRow( $(e.target).closest('tr') );
                        });
                      }
                    }
                  ]
                }
              ]
          });

    treeview = $elem.data('kendoTreeView');

    $('#upload-file').fileupload({
      url: '/iox/webpages/'+item.id+'/webfiles',
      dataType: 'json',
      formData: {
        "authenticity_token": $('input[name="authenticity_token"]:first').val()
      },
      dragover: function( e ){
        $(this).closest('.select-files').addClass('drop-here');
      },
      done: function (e, data) {
        var file = data._response.result;
        var self = this;
        setTimeout( function(){
          $(self).closest('.select-files').find('.progress').hide();
          $(self).closest('.select-files').find('.progress .bar').css( 'width', 0 );
          $(self).closest('.select-files').find('.progress-num').fadeOut();
          $('#upload-file').show();
        }, 1000 );
        // reload dataSource
        kGrid.data('kendoGrid').dataSource.read();
      },
      fail: function( response, type, msg ){
        console.log( response, type, msg );
        iox.flash.alert( JSON.parse(response.responseText).errors.file[0] );
      },
      submit: function( e, data ){
        $('#upload-file').hide();
        $(self).closest('.select-files').find('.progress').show();
        $(this).closest('.select-files').find('.progress-num').fadeIn();
      },
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $(this).closest('.select-files').find('.progress-num').text( progress + '%' );
        $(this).closest('.select-files').find('.progress .bar').css( 'width', progress + '%' );
      }
    });

  }

});
