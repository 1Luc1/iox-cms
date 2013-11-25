/**
* iox.positionImg
* positions an image within the
* relative (overflow:hidden) parent container
*
*/

$(function(){

  $.fn.ioxPositionImg = function ioxPositionImg( options ){

    if( $(this).length > 1 ){
      $(this).each( function(){
        $(this).ioxPositionImg( options );
      });
      return;
    }

    var $img = $(this);

    var origin = { x: 0, y: 0 };
    var clicked = false;

    $img.on('mousedown', function(e){
      e.preventDefault();
      clicked = true;
      origin = { x: e.pageX - parseInt($img.css('left')), y: e.pageY - parseInt($img.css('top')) };
    }).on('mouseup', function(e){
      e.preventDefault();
      clicked = false;
      var offset = {};
      offset.x = origin.x - e.pageX;
      offset.y = origin.y - e.pageY;
      if( offset.x > origin.x + 2 || offset.x < origin.x - 2 ||
           offset.y > origin.y + 2 || offset.y < origin.y - 2 )
        saveProjectFilePosition.call( $img, $img.css('left'), $img.css('top') );
    }).on('mousemove', function(e){
      e.preventDefault();
      if( !clicked )
        return;
      var offset = {};
      offset.x = origin.x - e.pageX;
      offset.y = origin.y - e.pageY;
      console.log( offset.x, offset.y );
      if( offset.y > 0 )
        if( $img.parent().height() < $img.height() - offset.y )
          $img.css({ top: (offset.y * -1) });
      else if( offset.y < 0 )
        if( $img.parent().height() > ($img.height() - offset.y) )
          $img.css({ top: offset.y });
      if( offset.x > 0 )
        if( $img.parent().width() < $img.width() - offset.x )
          $img.css({ left: (offset.x * -1) });
      else if( offset.x < 0 )
        if( $img.parent().width() > ($img.width() - offset.x) )
          $img.css({ left: offset.x });
    })

  }

  function saveProjectFilePosition( x, y ){
    $.ajax({
      url: '/openeras/files/'+$(this).attr('data-file-id')+'/coords',
      data: { size: $(this).attr('data-file-size'), 
              x: x.replace('px',''), 
              y: y.replace('px','') },
      dataType: 'json',
      type: 'post'
    }).done( function( response ){
      iox.flash.rails( response.flash );
      if( response.success )
        iox.flash.urge( 2000 );
    });
  }

});