$(document).ready ->

  $('textarea[ace-editor]').each ->
    editor = $(this).data('ace-div').data('ace-editor')
    editor.getSession().setUseSoftTabs(true)
    editor.getSession().setUseWrapMode(true)
    editor.setShowPrintMargin(false)
    editor.renderer.setShowGutter(false)
    
  $("#tag_field").select2({
      tags: $("#tag_field").data('tags'),
      tokenSeparators: [',', ' ']
      });