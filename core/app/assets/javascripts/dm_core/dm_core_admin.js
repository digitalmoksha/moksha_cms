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

});
