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
  	
  //----------------------------------------------------------------------
  
});
