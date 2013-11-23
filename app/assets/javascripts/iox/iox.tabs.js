/**
* iox-tabs
* lets you add a tabbed topbar
*
*/

$(function(){

  $.fn.ioxTabs = function ioxTabs( options ){

    var $tabContainer = $(this)
      , $tabsNav = $(this).find(' > ul:first')
      , $tabs = $(this).find(' > div');

    $tabsNav.find('li').on('click', function(e){
      e.preventDefault();
      if( $(this).hasClass('disabled') )
        return;
      $tabsNav.find('li').removeClass('active');
      $tabs.hide();
      $($tabs[$(this).index()]).show()
                            .addClass('active')
                            .find('.js-get-focus').focus();
      $(this).addClass('active');
    });

    // select either tab marked with 'active' or
    // first tab
    var $active = $tabsNav.find('li.active');
    if( !$active.length )
      $active = $tabsNav.first('li');
    $active.click();

  }

});