$(document).ready(function() {

  $("#cms_page_pagetype").change(function() {
    item = $('#cms_page_pagetype :selected').text();
    switch (item) {
      case 'content':
      case 'divider':
        $("#pagetype_link").hide();
        break;
      case 'pagelink':
      case 'link':
      case 'controller/action':
        $("#pagetype_link").show();
        break;
      default:
        break;
    }
  });
  $("#cms_page_pagetype").change(); // initially run on page load

  // When a link is selected in a bootstrap dropdown menu, set the
  // associated text field with the text
  //
  // <button class="btn dropdown-toggle" data-toggle="dropdown" >Folder</button>
  // <ul class="dropdown-menu dropdown-field" data-field="test">
  //   <li><a href="#"><i class="font-heart"></i>Favorite it</a></li>
  // </ul>
  // <input id="test" type="text">
  //----------------------------------------------------------------
  $(".dropdown-field li a").click(function(){
    $("#" + $(this).parent().parent().data("field")).val( $(this).text() )
  });
  
  //----------------------------------------------------------------
  $('#blog_user_table').dataTable( {
     bJQueryUI: false,
     bAutoWidth: false,
     sPaginationType: 'full_numbers',
     iDisplayLength: 10,
     bProcessing: false,
     bServerSide: true,
     bStateSave: false,
     aaSorting: [[0, 'asc']],
     sDom: '<"datatable-header"f>t<"datatable-footer">',
     oLanguage: {
       sLengthMenu: "<span>Show entries:</span> _MENU_"
     },
     sAjaxSource: $('#blog_user_table').data('source')
  });
  
  //----------------------------------------------------------------------
  
});
