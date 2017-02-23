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
      tabSize: 2,
      indentUnit: 2,
      lineWrapping: true,
      extraKeys: {
        'F11': (cm) ->
          cm.setOption("fullScreen", !cm.getOption("fullScreen"))

        'Esc': (cm) ->
          if (cm.getOption("fullScreen"))
            cm.setOption("fullScreen", false)

        'Tab': (cm) ->
          if (cm.somethingSelected())
            cm.indentSelection("add")
            return

          if cm.getOption('indentWithTabs')
            cm.replaceSelection("\t", "end", "+input")
          else
            cm.execCommand("insertSoftTab")

        "Shift-Tab": (cm) ->
          cm.indentSelection("subtract")
        
      }
    })

  # The CodeMirror needs to be refreshed if it was initially hidden in a tab
  # Refresh it when tab is clicked
  # http://stackoverflow.com/questions/20705905/bootstrap-3-jquery-event-for-active-tab-change
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    target = $(e.target).attr("href") # activated tab
    $(target + ' .CodeMirror').each (i, el) ->
      el.CodeMirror.refresh()
    
  $(".tag_field").select2({
    tags: true
  })

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
      
  $(document).on 'click', 'form .remove_custom_fields', (event) ->
    # $(this).prev('input[type=hidden]').val('1')
    # $(this).closest('fieldset').hide()
    $(this).closest('.custom_field_definition_box').children('._destroy').val('1')
    $(this).closest('.custom_field_definition_box').hide()
    event.preventDefault()

  $(document).on 'click', 'form .add_custom_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
