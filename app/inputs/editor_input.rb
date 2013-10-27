# Uses the Ace editor
#------------------------------------------------------------------------------
class EditorInput < SimpleForm::Inputs::TextInput
  def input
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
