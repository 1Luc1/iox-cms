//= require select2

//= require 3rdparty/jquery-ui-1.10.3.custom
//= require 3rdparty/bootstrap
//= require 3rdparty/moment-2.0.0.min

//= require 3rdparty/knockout

//= require iox/iox.core
//= require 3rdparty/jquery.ui.widget
//= require 3rdparty/jquery.iframe-transport
//= require 3rdparty/jquery.fileupload

//= require 3rdparty/noty/jquery.noty
//= require 3rdparty/noty/layouts/top
//= require 3rdparty/noty/themes/default

//=require_self

var imagesData;

$(document).ready( function(){

  //$('.webpage-mini-sidebar').draggable({ handle: '.iox-logo' });

  $('.webpage-sidebar button, .webpage-mini-sidebar button').on('click', function(e){

    if( !$(this).attr('data-href') && !$(this).attr('data-href-blank') && !$(this).attr('data-to-id') )
      return;

    e.preventDefault();

    if( $(this).attr('data-href') ){
      location = $(this).attr('data-href');
      return;
    }

    if( $(this).attr('data-href-blank') ){
      window.open( $(this).attr('data-href-blank') );
      return;
    }

    if( $(this).hasClass('active') )
      return;
    $('.webpage-tabs-control button.active').removeClass('active');
    $('.webpage-tab.active').removeClass('active').hide();
    $('#webpage-tab-'+$(this).attr('data-to-id')).addClass('active').fadeIn();
    $(this).addClass('active');
  });

  // don't proceed if not .webpage-sidebar
  // only proceed if in edit mode
  if( $('.webpage-sidebar').length < 1 )
    return;

  if( $('.webpage-sidebar .webbit-list ul').height() > $(document).height()/2-200 )
    $('.webpage-sidebar .webbit-list ul').height( $(document).height()-$(document).height()/2-200);

  $('.webpage-form').off('submit').on('submit', function(e){
    $(this).find('.webbit-meta-info-clone').remove();
    $metaInfo = $('<div style="display:none"/>');
    $('.webbit-meta-info').each( function(){
      $metaInfo.append( $(this).clone() );
    });
    $(this).append( $metaInfo );

    var self = this;
    setTimeout( function(){
      $.ajax({ url: $(self).attr('action'),
        data: $(self).serializeArray(),
        dataType: 'json',
        type: 'put'
      }).done(function(response){
        if( response.flash.length > 0 && response.flash[0].length > 0 )
          noty({text: response.flash[0][1]});
      });
    }, 100);

    return false;
  });

	$('.webbit').on('click', function(e){

		if( $(this).hasClass('active') ){
			return;
		}

    $('.webbit').css('z-index','auto');
    $(this).css('z-index', 999);

    $('.webbit-list li.active').removeClass('active');
    $('.webbit-list li[data-webbit-id='+$(this).attr('id')+']').addClass('active');

		$('.webbit.active').removeClass('active');

		$(this).addClass('active');

    $('.webbit-plugin-control').hide();
		$('#webpage-tab-webbit .webbit-'+$(this).attr('data-plugin-name')+'-plugin').show();
		$('.webpage-tabs-control [data-to-id=webbit]').click();
	});

	$('.webpage-tab').hide();
	$('.webpage-tab.active').show();

  $(".select2").select2();
  $(".select2tags").select2({
    tags: [],
    tokenSeparators: [","]
  });

  $('.slider-button').click(function() {
    if ($(this).hasClass("on")) {
      $(this).removeClass('on').html($(this).data("off-text"));
      $(this).parent().removeClass('success');
    } else {
      $(this).addClass('on').html($(this).data("on-text"));
      $(this).parent().addClass('success');
    }
  });

  $('.publish-button').on('click', function(){
    $.ajax({ url: $(this).attr('data-href'),
             type: 'put',
             dataType: 'json',
             data: { publish: $(this).hasClass('on') },
             success: function( data ){
               iox.flash( data );
             }
    });
  });

  $('.webbit-list li').on('click', function(e){
    $('#'+$(this).attr('data-webbit-id')).click();
  });

  // clear any actions for the anchor elements within webbit list
  $('.webbit-list a').on('click', function(e){
    e.preventDefault();
  })

  $('.webpage-sidebar').draggable({ handle: '.iox-logo' });

  $('.flash-container .alert').on('click', function(e){
    $(this).effect('drop');
  });

  imagesData = { images: ko.observableArray() };

  $('.image-browser').on('click', '.icon-remove', function(e){
    var img = ko.dataFor($(this).closest('li').get(0));
    $.ajax({ url: 'webfiles/'+img.id, type: 'delete', dataType: 'json', success: function( json ){
        if( json.success ){
          imagesData.remove( member );
        }
      }
    })
  });

});
