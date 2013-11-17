//= require 3rdparty/password-generator.min
//= require 3rdparty/jquery.fileupload
//= require iox/webfiles

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

});