$(document).ready ->

  #--- Setting Datatable defaults
  $.extend( $.fn.dataTable.defaults, {
    autoWidth: false,
    pagingType: 'full_numbers',
    language: {
      search: '<span>Filter:</span> _INPUT_',
      lengthMenu: '<span>Show:</span> _MENU_',
      paginate: { 'first': 'First', 'last': 'Last', 'next': '>', 'previous': '<' }
    }
  })

  #--- Add fadeIn animation to dropdown
  $('.dropdown, .btn-group').on 'show.bs.dropdown', ->
    $(this).find('.dropdown-menu').first().stop(true, true).fadeIn(100)

  #--- Add fadeOut animation to dropdown
  $('.dropdown, .btn-group').on 'hide.bs.dropdown', ->
    $(this).find('.dropdown-menu').first().stop(true, true).fadeOut(100)

  #--- Prevent dropdown from closing on click
  $('.popup').click (e) ->
    e.stopPropagation()

  #--- Sparkline charts
  $('.bar-danger').sparkline(
    'html', {type: 'bar', barColor: '#D65C4F', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )
  $('.bar-success').sparkline(
    'html', {type: 'bar', barColor: '#65B688', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )
  $('.bar-primary').sparkline(
    'html', {type: 'bar', barColor: '#32434D', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )
  $('.bar-warning').sparkline(
    'html', {type: 'bar', barColor: '#EE8366', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )
  $('.bar-info').sparkline(
    'html', {type: 'bar', barColor: '#3CA2BB', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )
  $('.bar-default').sparkline(
    'html', {type: 'bar', barColor: '#ffffff', height: '35px', barWidth: "5px", barSpacing: "2px", zeroAxis: "false"}
  )

  # Activate hidden Sparkline on tab show
  $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
    $.sparkline_display_visible()

  # Activate hidden Sparkline
  $('.collapse').on 'shown.bs.collapse', ->
    $.sparkline_display_visible()

  #--- Bootstrap3 datetime picker and SimpleForm inputs
  $('.datepicker_control').datetimepicker({
    pickTime: false,
    icons: {
        time: "fa fa-clock-o",
        date: "fa fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
    }
  })

  $('.datetimepicker_control').datetimepicker({
    pickSeconds: false,
    icons: {
        time: "fa fa-clock-o",
        date: "fa fa-fw fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
    }
  })

  $('.timepicker_control').datetimepicker({
    pickDate: false,
    pickSeconds: false,
    icons: {
        time: "fa fa-clock-o",
        date: "fa fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
    }
  })

  #--- Bootstrap color picker
  $('.colorpicker-component').colorpicker()
