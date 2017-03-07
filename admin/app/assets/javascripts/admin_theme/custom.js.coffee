$(document).ready ->

  # Bootstrap Plugins
  #------------------------------------------------------------------------------

  # Data tables
  #==================================================


  #===== Setting Datatable defaults =====//

  $.extend( $.fn.dataTable.defaults, {
    autoWidth: false,
    pagingType: 'full_numbers',
    language: {
      search: '<span>Filter:</span> _INPUT_',
      lengthMenu: '<span>Show:</span> _MENU_',
      paginate: { 'first': 'First', 'last': 'Last', 'next': '>', 'previous': '<' }
    }
  })

  #===== Add fadeIn animation to dropdown =====

  $('.dropdown, .btn-group').on 'show.bs.dropdown', ->
    $(this).find('.dropdown-menu').first().stop(true, true).fadeIn(100)

  #===== Add fadeOut animation to dropdown =====

  $('.dropdown, .btn-group').on 'hide.bs.dropdown', ->
    $(this).find('.dropdown-menu').first().stop(true, true).fadeOut(100)

  #===== Prevent dropdown from closing on click =====

  $('.popup').click (e) ->
    e.stopPropagation()


  # Form Related Plugins
  #------------------------------------------------------------------------------

  #===== Elastic textarea =====
  
  # $('.elastic').autosize();

  #===== Tags Input =====
  
  # $('.tags').tagsInput({width:'100%'});
  # $('.tags-autocomplete').tagsInput({
  #   width:'100%',
  #   autocomplete_url:'tags_autocomplete.html'
  # });

  #===== Form elements styling =====

  # $(".styled, .multiselect-container input").uniform({ radioClass: 'choice', selectAutoWidth: false })

  #===== Sparkline charts =====
  
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

  # for the Bootstrap3 datetime picker and SimpleForm inputs
  #------------------------------------------------------------------------------  
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
  

  #===== DateRangePicker plugin =====

  # $('#reportrange').daterangepicker(
  #   {
  #     startDate: moment().subtract('days', 29),
  #     endDate: moment(),
  #     minDate: '01/01/2012',
  #     maxDate: '12/31/2014',
  #     dateLimit: { days: 60 },
  #     ranges: {
  #       'Today': [moment(), moment()],
  #       'Yesterday': [moment().subtract('days', 1), moment().subtract('days', 1)],
  #       'Last 7 Days': [moment().subtract('days', 6), moment()],
  #       'This Month': [moment().startOf('month'), moment().endOf('month')],
  #       'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')]
  #     }
  #     opens: 'left',
  #     buttonClasses: ['btn'],
  #     applyClass: 'btn-small btn-info btn-block',
  #     cancelClass: 'btn-small btn-default btn-block',
  #     format: 'MM/DD/YYYY',
  #     separator: ' to ',
  #     locale: {
  #       applyLabel: 'Submit',
  #       fromLabel: 'From',
  #       toLabel: 'To',
  #       customRangeLabel: 'Custom Range',
  #       daysOfWeek: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr','Sa'],
  #       monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  #       firstDay: 1
  #     }
  #   },
  #   (start, end) ->
  #     $.jGrowl('A date range was changed', { header: 'Update', position: 'center', life: 1500 });
  #     $('#reportrange .date-range').html(start.format('<i>D</i> <b><i>MMM</i> <i>YYYY</i></b>') + '<em> - </em>' + end.format('<i>D</i> <b><i>MMM</i> <i>YYYY</i></b>'));
  # )
  #
  # # Custom date display layout
  # $('#reportrange .date-range').html(moment().subtract('days', 29).format('<i>D</i> <b><i>MMM</i> <i>YYYY</i></b>') + '<em> - </em>' + moment().format('<i>D</i> <b><i>MMM</i> <i>YYYY</i></b>'));
  # $('#reportrange').on 'show', ->
  #   $('.range').addClass('range-shown')
  #
  # $('#reportrange').on 'hide', ->
  #   $('.range').removeClass('range-shown')


  # Default Layout Options
  #------------------------------------------------------------------------------

  # #===== Wrapping content inside .page-content =====
  #
  # $('.page-content').wrapInner('<div class="page-content-inner"></div>')
  #
  # #===== Applying offcanvas class =====
  #
  # $(document).on 'click', '.offcanvas', ->
  #   $('body').toggleClass('offcanvas-active')
  #
  # #===== Default navigation =====
  #
  # $('.navigation').find('li.active').parents('li').addClass('active')
  # $('.navigation').find('li').not('.active').has('ul').children('ul').addClass('hidden-ul')
  # $('.navigation').find('li').has('ul').children('a').parent('li').addClass('has-ul')
  #
  # $(document).on 'click', '.sidebar-toggle', (e) ->
  #   e.preventDefault()
  #
  #   $('body').toggleClass('sidebar-narrow')
  #
  #   if ($('body').hasClass('sidebar-narrow'))
  #     $('.navigation').children('li').children('ul').css('display', '')
  #
  #     $('.sidebar-content').hide().delay().queue ->
  #       $(this).show().addClass('animated fadeIn').clearQueue();
  #
  #     $.cookie('admin_sidebar_narrow', 'true', { expires: 365, path: '/' }) # save state
  #   else
  #     $('.navigation').children('li').children('ul').css('display', 'none')
  #     $('.navigation').children('li.active').children('ul').css('display', 'block')
  #
  #     $('.sidebar-content').hide().delay().queue ->
  #       $(this).show().addClass('animated fadeIn').clearQueue()
  #
  #     $.removeCookie('admin_sidebar_narrow', { path: '/' }) # remove state
  #
  # $('.navigation').find('li').has('ul').children('a').on 'click', (e) ->
  #   e.preventDefault();
  #
  #   if ($('body').hasClass('sidebar-narrow'))
  #     $(this).parent('li > ul li').not('.disabled').toggleClass('active').children('ul').slideToggle(250)
  #     $(this).parent('li > ul li').not('.disabled').siblings().removeClass('active').children('ul').slideUp(250)
  #   else
  #     $(this).parent('li').not('.disabled').toggleClass('active').children('ul').slideToggle(250)
  #     $(this).parent('li').not('.disabled').siblings().removeClass('active').children('ul').slideUp(250)
  #
  #
  #
  # #===== Disabling main navigation links =====
  #
  # $('.navigation .disabled a, .navbar-nav > .disabled > a').click (e) ->
  #   e.preventDefault()
