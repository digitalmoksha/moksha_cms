

// Function for toggling the revealing of an item, through slide and fading
//----------------------------------------------------------------
function toggle_reveal(item, options) {
  options          = (typeof options == 'undefined') ? {duration:500} : options;
  options.duration = (typeof options.duration == 'undefined') ? 500 : options.duration;
  $(item).animate({
    height: 'toggle', 
    opacity: 'toggle' 
  }, options.duration);
}

//------------------------------------------------------------------------------

$(document).ready(function() {
  
  //----------------------------------------------------------------
  $('#drag_sort').sortable({
    axis: 'y',
    dropOnEmpty: false,
    cursor: 'crosshair',
    items: '.item',
    opacity: 0.4,
    scroll: true,
    update: function(e, ui) {
      var item_id = ui.item.data('item_id');
      var position = ui.item.index();
      $.ajax({
        type: 'POST',
        url: $(this).data('update_url'),
        dataType: 'json',
        data: { id: item_id, item: { row_order_position: position } }
      })
    }
  });
  
  //----------------------------------------------------------------
	$(".notice").click(function() {
		$(this).fadeTo(200, 0.00, function(){ //fade
			$(this).slideUp(200, function() { //slide up
				$(this).remove(); //then remove from the DOM
			});
		});
	});	
  
	$('#new_user_sparkline').sparkline(
		'html', {type: 'bar', barColor: '#a6c659', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
	);
	$('#access_user_sparkline').sparkline(
		'html', {type: 'bar', barColor: '#a6c659', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
	);

  // Toggle the visibility of a specific element
  //----------------------------------------------------------------
  $(".toggle_link").live("click", function(et, e){
    toggle_reveal(this.getAttribute("data-toggleid"));
    return false;
  });

  //----------------------------------------------------------------
  $('#user_table').dataTable( {
     bJQueryUI: false,
     bAutoWidth: false,
     sPaginationType: 'full_numbers',
     bProcessing: false,
     bServerSide: true,
     aaSorting: [[2, 'asc']],
     sDom: '<"datatable-header"fl>t<"datatable-footer"ip>',
     aoColumnDefs: [
       { bSortable: false, aTargets: [ 5 ] },
       { bSortable: false, aTargets: [ 6 ] }
     ],
 		 oLanguage: {
 		   sLengthMenu: "<span>Show entries:</span> _MENU_"
 		 },
     sAjaxSource: $('#user_table').data('source')
  });

	$( ".datepicker" ).datepicker({
				defaultDate: +7,
		showOtherMonths:true,
		autoSize: true,
		appendText: '(yyyy-mm-dd)',
		dateFormat: 'yy-mm-dd'
		});
		
  //----------------------------------------------------------------
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
