// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require codemirror
//= require codemirror/addons/mode/overlay
//= require codemirror/addons/edit/continuelist
//= require codemirror/addons/display/fullscreen
//= require codemirror/modes/xml
//= require codemirror/modes/css
//= require codemirror/modes/javascript
//= require codemirror/modes/htmlmixed
//- require codemirror/modes/htmlembedded
//= require codemirror/modes/markdown
//= require codemirror/modes/gfm
//= require dm_core/admin_extra.js

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

  // For any div that has a data-load attribute, load up the supplied url and put in div.
  // For example:
  //   <div id="widget_lesson_comments" data-load="<%= dm_lms.admin_widget_lesson_comments_path(comment_day: 0) %>">
  //   </div>
  //----------------------------------------------------------------
  $("div[data-load]").filter(":visible").each(function(){
    var path = $(this).attr('data-load');
    $(this).load(path);
  });

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
    li = $(this).parent().parent().parent();
    toggle_reveal(li.children('ul'));
    cookie_name = 'page_tree_' + li.data('item_id');
    if ($.cookie(cookie_name) == '1') {
      $.removeCookie(cookie_name);
    } else {
      $.cookie(cookie_name, '1', { expires: 365 });
    }
    return false;
  });

  // https://github.com/jhfrench/bootstrap-tree
	//------------------------------------------------------------------------------
	$('.tree > ul').attr('role', 'tree').find('ul').attr('role', 'group');
	$('.tree').find('li:has(ul)').addClass('parent_li').attr('role', 'treeitem').find(' > span').attr('title', 'Collapse this branch').on('click', function (e) {
        // var children    = $(this).parent('li.parent_li').find(' > ul > li');
        var children    = $(this).parent('li.parent_li').find(' > ul');
        var cookie_name = $(this).parent('li.parent_li').data('save_id');
        if (children.is(':visible')) {
      		children.hide('fast');
      		$(this).attr('title', 'Expand this branch').find(' > i').addClass('fa-plus-square-o').removeClass('fa-minus-square-o');
          $.removeCookie(cookie_name, { path: '/' });
        }
        else {
      		children.show('fast');
      		$(this).attr('title', 'Collapse this branch').find(' > i').addClass('fa-minus-square-o').removeClass('fa-plus-square-o');
          $.cookie(cookie_name, '1', { expires: 365, path: '/' });
        }
        e.stopPropagation();
    });

  //----------------------------------------------------------------
  $(".notice, .alert").click(function() {
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
  $(".toggle_link").on("click", function(et, e){
    toggle_reveal(this.getAttribute("data-toggleid"));
    return false;
  });

  //----------------------------------------------------------------
  $('#user_table').dataTable( {
     bJQueryUI: false,
     iDisplayLength: 50,
     bProcessing: false,
     bServerSide: true,
     bStateSave: true,
     aaSorting: [[4, 'desc']],
     aoColumnDefs: [
       { bSortable: false, aTargets: [ 0 ] },
       { bSortable: false, aTargets: [ 5 ] }
     ],
     sAjaxSource: $('#user_table').data('source')
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

  // Attach tooltip to any class with 'hovertip' inside the main content
  // block.  Must do this way to ensure tooltips work in new ajax content
  //----------------------------------------------------------------
  $('.page-container').tooltip( {
    selector: '.hovertip',
    delay: {show: 200, hide: 0 }
  });

});
