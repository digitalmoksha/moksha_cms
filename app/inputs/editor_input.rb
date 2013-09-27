# Uses the Ace editor
#------------------------------------------------------------------------------
class EditorInput < SimpleForm::Inputs::TextInput
  def input
    input_html_options['ace-editor']  = ""
    input_html_options['ace-mode']    = 'markdown' if options[:mode].blank?
    input_html_options['ace-theme']   = 'crimson_editor' if options[:theme].blank?
    super
  end
end
