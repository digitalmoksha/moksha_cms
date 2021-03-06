#------------------------------------------------------------------------------
class ToggleCheckedInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options)
    out = '<div class="on_off">'
    out << @builder.check_box(attribute_name, input_html_options)
    out << '</div>'
    out
  end
end
