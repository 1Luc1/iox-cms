//= require 3rdparty/password-generator.min
//= require 3rdparty/jquery.fileupload

$(function(){

  if( $('.user-profile').length ){

    $('.user-upload-avatar').fileupload({
      dataType: 'json',
      formData: {
        "authenticity_token": $('input[name="authenticity_token"]:first').val()
      },
      done: function (e, data) {
        var avatar = data._response.result[0];
        $('.avatar-thumb[data-user-id='+avatar.id+']').attr('src', avatar.thumbnail_url);
        $('.avatar[data-user-id='+avatar.id+']').attr('src', avatar.url);
      }
    });

  }

});