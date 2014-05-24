$(document).ready ->

  #--- using the CodeMirror editor
  $('textarea[codemirror-editor]').each ->
    mode = $(this).data('mode')
    theme = $(this).data('theme')
    editor = CodeMirror.fromTextArea(this, {
      lineNumbers: false,
      mode: {name: mode, underscoresBreakWords: false},
      theme: theme,
      indentWithTabs: false,
      lineWrapping: true
    })

  # The CodeMirror needs to be refreshed if it was initially hidden in a tab
  # Refresh it when tab is clicked
  # http://stackoverflow.com/questions/20705905/bootstrap-3-jquery-event-for-active-tab-change
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    target = $(e.target).attr("href") # activated tab
    $(target + ' .CodeMirror').each (i, el) ->
      el.CodeMirror.refresh()
    
  $("#tag_field").select2({
      tags: $("#tag_field").data('tags'),
      tokenSeparators: [',', ' ']
      });

