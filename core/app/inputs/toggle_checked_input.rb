#------------------------------------------------------------------------------
class ToggleCheckedInput < SimpleForm::Inputs::BooleanInput
  def input
    out = '<div class="on_off">'
    out << @builder.check_box(attribute_name, input_html_options)
    out << '</div>'
    return out
  end
end
