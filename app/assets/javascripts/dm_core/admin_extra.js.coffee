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
      lineWrapping: true,
      extraKeys: {
        "F11": (cm) ->
          cm.setOption("fullScreen", !cm.getOption("fullScreen"))
        "Esc": (cm) ->
          if (cm.getOption("fullScreen"))
            cm.setOption("fullScreen", false)
      }
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

  # Toolbar commands for the CodeMirror editor
  #------------------------------------------------------------------------------
  $('.cm_cmd_fullscreen').on 'click', (e) ->
    editor_id = $(this).data('editor')
    $(editor_id + ' .CodeMirror')[0].CodeMirror.setOption("fullScreen", true)
    $(editor_id + ' .CodeMirror')[0].CodeMirror.focus()
    
  $('.cm_cmd_bold_markdown').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "**#{text}**"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()

  $('.cm_cmd_bold_textile').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "*#{text}*"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()

  $('.cm_cmd_italic_markdown').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "_#{text}_"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()

  $('.cm_cmd_italic_textile').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "_#{text}_"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()

  $('.cm_cmd_link_markdown').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "[#{text}]()"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()

  $('.cm_cmd_link_textile').on 'click', (e) ->
    editor_id = $(this).data('editor')
    editor    = $(editor_id + ' .CodeMirror')[0].CodeMirror
    text      = editor.doc.getSelection()
    new_text  = "\"#{text}\":"
    editor.doc.replaceSelection(new_text)
    editor.cm.focus()
      
    
