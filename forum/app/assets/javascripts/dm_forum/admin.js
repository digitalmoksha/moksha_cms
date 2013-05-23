$(document).ready(function() {
  
  //----------------------------------------------------------------
  $('#forum_user_table').dataTable( {
     bJQueryUI: false,
     bAutoWidth: false,
     sPaginationType: 'full_numbers',
     iDisplayLength: 10,
     bProcessing: false,
     bServerSide: true,
     bStateSave: false,
     aaSorting: [[0, 'asc']],
     sDom: '<"datatable-header"f>t<"datatable-footer">',
     aoColumnDefs: [
//       { bSortable: false, aTargets: [ 5 ] },
//       { bSortable: false, aTargets: [ 6 ] }
     ],
     oLanguage: {
       sLengthMenu: "<span>Show entries:</span> _MENU_"
     },
     sAjaxSource: $('#forum_user_table').data('source')
  });

});
