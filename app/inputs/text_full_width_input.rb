#------------------------------------------------------------------------------
class TextFullWidthInput < SimpleForm::Inputs::TextInput
  def input
    input_html_classes << 'input-block-level'
    input_html_classes << ' monospaced' if options[:mono]
    input_html_options[:rows] = options[:rows] if options[:rows]
    super
  end
end
