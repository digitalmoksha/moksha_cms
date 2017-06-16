$(document).ready(function() {
  
  //------------------------------------------------------------------------------
  function addCommas(nStr)
  {
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  }
  
  //------------------------------------------------------------------------------
  $('#registration_table').dataTable( {
     bJQueryUI: false,
     iDisplayLength: 50,
     bProcessing: false,
     bServerSide: true,
     bStateSave: true,
     aaSorting: [[4, 'desc']],
    aoColumnDefs: [
      { bSortable: false, aTargets: [ 3 ] }
     ],
     sAjaxSource: $('#registration_table').data('source'),
     bDestroy: true,
     bRetrieve: true
  });

  //------------------------------------------------------------------------------
  var unpaid_participants_table = $('#unpaid_participants_table').DataTable({
    pageLength: 50,
    orderFixed: [2, 'asc'],
    rowGroup: { 
      dataSrc: 2,
      endRender: function ( rows, group ) {
          var totalBalance = rows
              .data()
              .pluck(3)
              .reduce( function (a, b) {
                  return a + b.replace(/[^\d]/g, '')*1;
              }, 0) / 100;
          totalBalance = $.fn.dataTable.render.number(',', '.', 2, '').display( totalBalance );

          return $('<tr/>')
              .append( '<td colspan="3" style="text-align:right">Total Balance: </td>' )
              .append( '<td>'+totalBalance+'</td>' )
              .append( '<td/>' )
              .append( '<td/>' )
              .append( '<td/>' );
      }
    },
    columnDefs: [
      { "targets": 0,     "orderData": 7},
      { "targets": 5,     "orderData": 8},
      { "targets": [ 7, 8 ], "visible": false}
    ]
  });
  
  $('#unpaid_participants_table a.group-by').on( 'click', function (e) {
    var column = $(this).data('column');
    e.preventDefault();
    if (column == 'none') {
      unpaid_participants_table.order.fixed( {pre: []} );
      unpaid_participants_table.rowGroup().disable().draw();  
    } else {
      unpaid_participants_table.rowGroup().enable();  
      unpaid_participants_table.rowGroup().dataSrc( column );      
      unpaid_participants_table.order.fixed( {pre: [[ column, 'asc' ]]} ).draw();
    }
  } );


  //------------------------------------------------------------------------------
  var writeoffs_table = $('#writeoffs_table').DataTable({
    pageLength: 25,
    orderFixed: [2, 'asc'],
    rowGroup: { 
      dataSrc: 2,
      endRender: function ( rows, group ) {
          var totalBalance = rows
              .data()
              .pluck(3)
              .reduce( function (a, b) {
                  return a + b.replace(/[^\d]/g, '')*1;
              }, 0) / 100;
          totalBalance = $.fn.dataTable.render.number(',', '.', 2, '').display( totalBalance );

          return $('<tr/>')
              .append( '<td colspan="3" style="text-align:right">Total Balance: </td>' )
              .append( '<td>'+totalBalance+'</td>' )
              .append( '<td/>' )
              .append( '<td/>' )
              .append( '<td/>' );
      }
    },
    columnDefs: [
      { "targets": 0,     "orderData": 5},
      { "targets": 4,     "orderData": 6},
      { "targets": [ 5, 6 ], "visible": false}
    ]
  });
  
  $('#writeoffs_table a.group-by').on( 'click', function (e) {
    var column = $(this).data('column');
    e.preventDefault();
    if (column == 'none') {
      writeoffs_table.order.fixed( {pre: []} );
      writeoffs_table.rowGroup().disable().draw();  
    } else {
      writeoffs_table.rowGroup().enable();  
      writeoffs_table.rowGroup().dataSrc( column );      
      writeoffs_table.order.fixed( {pre: [[ column, 'asc' ]]} ).draw();
    }
  } );
  

  // Financial charts
  //------------------------------------------------------------------------------
  
  if ($('#payment_outstanding_chart').length) {
    $('#payment_outstanding_chart').plot($('#payment_outstanding_chart').data('values'), {
      series: {
        pie: {
          show: true
        }
      }
    });
  }

  if ($('#collected_chart').length) {
    $('#collected_chart').plot($('#collected_chart').data('values'), {
      series: {
        pie: {
          show: true
        }
      }
    });
  }

  if ($('#collected_monthly_chart').length) {
    var $collected_monthly_chart = $('#collected_monthly_chart')
    $collected_monthly_chart.plot( [ $collected_monthly_chart.data('values') ], {
      series: {
        color: '#009800',
        bars: {
          show: true,
          barWidth: 0.5,
          align: "center",
          lineWidth: 0,
          fill: true,
          fillColor: { colors: [ { opacity: 0.8 }, { opacity: 0.3 } ] },
        }
      },
      grid: {
        borderWidth: 1,
        borderColor: '#999'
      },
      xaxis: {
        mode: "categories",
        tickLength: 0,
      },
      yaxis: {
        tickFormatter: function(value, axis) {
          return $collected_monthly_chart.data('currencysymbol') + addCommas(value.toFixed(axis.tickDecimals));
        }
      }
    });
  }
  
});


