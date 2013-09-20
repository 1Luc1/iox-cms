// Register a template definition set named "default".
CKEDITOR.addTemplates( 'default',
{
  // The name of the subfolder that contains the preview images of the templates.
  imagesPath : CKEDITOR.getUrl( CKEDITOR.plugins.getPath( 'templates' ) + 'templates/images/' ),
 
  // Template definitions.
  templates :
    [
      {
        title: 'Newsticker',
        image: 'template1.gif',
        description: 'Einen Newstickereintrag hinzufügen',
        html:
          '<div class="news-entry">' +
          '<h1>Titel des Beitrages</h1>' +
          '<p class="date">'+ moment().format('ddd, DD. MMMM YYYY')+'</p>' +
          '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur eros justo, tincidunt tincidunt luctus in, porta vitae nisi. Mauris et ultricies urna, vitae condimentum risus. Suspendisse et vehicula elit. Phasellus nunc massa, volutpat vel rutrum ut, faucibus ac orci. Etiam non risus non neque laoreet viverra. Cras eget fermentum ipsum. Integer facilisis semper urna non venenatis. Nulla facilisi. Proin lacinia magna at nulla blandit, eu venenatis nunc semper. </p>'+
          '</div>'
      }
    ]
});