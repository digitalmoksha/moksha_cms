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


