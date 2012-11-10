//------------------------------------------------------------------------------

$(document).ready(function() {
  $('#user_table').dataTable( {
     bJQueryUI: false,
     bAutoWidth: false,
     sPaginationType: 'full_numbers',
     bProcessing: false,
     bServerSide: true,
     aaSorting: [[2, 'asc']],
     sDom: '<"H"fl>tr<"F"ip>',
     aoColumnDefs: [
       { bSortable: false, aTargets: [ 5 ] },
       { bSortable: false, aTargets: [ 6 ] }
     ],
     sAjaxSource: $('#user_table').data('source')
  });

  $.fn.toolbarTabs = function(){ 
  
    $(this).find(".tab_content").hide(); //Hide all content
    $(this).find("ul.tabs.toolbar li:first").addClass("activeTab").show(); //Activate first tab
    $(this).find(".tab_content:first").show(); //Show first tab content
  
    $("ul.tabs.toolbar li").click(function() {
      $(this).parent().parent().find("ul.tabs li").removeClass("activeTab"); //Remove any "active" class
      $(this).addClass("activeTab"); //Add "active" class to selected tab
      $(this).parent().parent().parent().find(".tab_content").hide(); //Hide all tab content
      var activeTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
      $(activeTab).show(); //Fade in the active content
      return false;
    });
  
  };
  $("div[class^='widget']").toolbarTabs(); //Run function on any div with class name of "Content Tabs"

});
