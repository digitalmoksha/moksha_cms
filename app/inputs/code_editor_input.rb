# Uses the CodeMirror editor
#------------------------------------------------------------------------------
class CodeEditorInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options)
    if options[:mode]
      options[:mode] = case options[:mode].downcase
      when 'textile'
        :htmlmixed  # no textile mode available
      when 'markdown'
        :markdown
      when 'html'
        :htmlmixed
      else
        :markdown
      end
    end
    input_html_options['codemirror-editor']   = ""
    input_html_options['data-mode']           = options[:mode] || :markdown
    input_html_options['data-theme']          = options[:theme] || :default
    super
  end
end
