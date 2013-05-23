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
      { bSortable: false, aTargets: [ 3 ] }
     ],
     oLanguage: {
       sLengthMenu: "<span>Show entries:</span> _MENU_"
     },
     sAjaxSource: $('#registration_table').data('source')
  });

  $('#registration_table').tooltip( {
    selector: '.hovertip',
    delay: {show: 200, hide: 0 }
  });
});
