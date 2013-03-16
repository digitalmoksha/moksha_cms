#------------------------------------------------------------------------------
class ToggleInput < SimpleForm::Inputs::BooleanInput
  def input
    out = '<div class="yes_no">'
    out << @builder.check_box(attribute_name, input_html_options)
    out << '</div>'
    return out
  end
end
