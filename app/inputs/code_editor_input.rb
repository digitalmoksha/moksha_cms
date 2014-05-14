# Uses the Ace editor
#------------------------------------------------------------------------------
class CodeEditorInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options)
    if options[:mode]
      options[:mode] = case options[:mode].downcase
      when 'textile'
        :liquid 
      when 'markdown'
        :markdown
      when 'html'
        :html
      else
        :markdown
      end
    end
    input_html_options['ace-editor']  = ""
    input_html_options['ace-mode']    = options[:mode] || :markdown
    input_html_options['ace-theme']   = options[:theme] || 'crimson_editor'
    super
  end
end
