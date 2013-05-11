$(document).ready(function() {
  
  //----------------------------------------------------------------
  $('#registration_table').dataTable( {
     bJQueryUI: false,
     bAutoWidth: false,
     sPaginationType: 'full_numbers',
     iDisplayLength: 50,
     bProcessing: false,
     bServerSide: true,
     bStateSave: true,
     aaSorting: [[2, 'asc']],
     sDom: '<"datatable-header"fl>t<"datatable-footer"ip>',
     aoColumnDefs: [
//       { bSortable: false, aTargets: [ 5 ] },
//       { bSortable: false, aTargets: [ 6 ] }
     ],
     oLanguage: {
       sLengthMenu: "<span>Show entries:</span> _MENU_"
     },
     sAjaxSource: $('#registration_table').data('source')
  });

});
