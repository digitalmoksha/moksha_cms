$(document).ready(function() {
  
  //----------------------------------------------------------------
  $('#forum_user_table').dataTable( {
     bJQueryUI: false,
     iDisplayLength: 10,
     bProcessing: false,
     bServerSide: true,
     bStateSave: false,
     aaSorting: [[0, 'asc']],
     sAjaxSource: $('#forum_user_table').data('source')
  });

});
