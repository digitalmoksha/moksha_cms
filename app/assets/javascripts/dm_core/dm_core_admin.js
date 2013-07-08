

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
    cursor: 'row-resize',
    items: '.item',
    handle: '.sort_handle',
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
  
  // http://boagworld.com/dev/creating-a-draggable-sitemap-with-jquery/
  //----------------------------------------------------------------------
  $('#tree_sort li').prepend('<div class="dropzone"></div>');

  $('#tree_sort li').draggable({
      handle: ' > dl',
      opacity: .8,
      addClasses: false,
      helper: 'clone',
      zIndex: 100
  });
  
  $('#tree_sort dl, #tree_sort .dropzone').droppable({
    accept: '#tree_sort li',
    tolerance: 'pointer',
    drop: function(e, ui) {
      var li        = $(this).parent();
      var add_child = !$(this).hasClass('dropzone');
      //--- If this is our first child, we'll need a ul to drop into.
      if (add_child && li.children('ul').length == 0) {
        li.append('<ul/>');
      }
      //--- ui.draggable is our reference to the item that's been dragged.
      if (add_child) {
        li.children('ul').append(ui.draggable);
      }
      else {
        li.before(ui.draggable);
      }
      
      //--- send update to the server
      var item_id   = ui.draggable.data('item_id');
      var position  = ui.draggable.index();
      if (add_child) {
        var parent_id = li.data('item_id');
      }
      else {
        var parent_id = li.parents('li').first().data('item_id');        
      }
      $.ajax({
        type: 'POST',
        url: $('#tree_sort').data('update_url'),
        dataType: 'json',
        data: { id: item_id, item: { position: position, parent_id: parent_id } }
      })
      
      //--- reset our background colours.
      li.find('dl,.dropzone').css({ backgroundColor: '', borderColor: '' });
    },
    over: function() {
      $(this).filter('dl').css({ backgroundColor: '#ccc' });
      $(this).filter('.dropzone').css({ borderColor: '#aaa' });
    },
    out: function() {
      $(this).filter('dl').css({ backgroundColor: '' });
      $(this).filter('.dropzone').css({ borderColor: '' });
    }
  });
  
  $('.tree_expand').on('click', function() {
    $(this).parent().parent().parent().toggleClass('tree_open').toggleClass('tree_closed');
    li = $(this).parent().parent().parent()
    toggle_reveal(li.children('ul'));
    return false;
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
     iDisplayLength: 50,
     sPaginationType: 'full_numbers',
     bProcessing: false,
     bServerSide: true,
     bStateSave: true,
     aaSorting: [[4, 'desc']],
     sDom: '<"datatable-header"fl>t<"datatable-footer"ip>',
     aoColumnDefs: [
       { bSortable: false, aTargets: [ 0 ] },
       { bSortable: false, aTargets: [ 5 ] }
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
