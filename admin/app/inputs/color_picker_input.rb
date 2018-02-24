class ColorPickerInput < SimpleForm::Inputs::StringInput
  #------------------------------------------------------------------------------
  def input(wrapper_options)
    template.content_tag :div, class: 'input-group colorpicker-component' do
      input  = super(wrapper_options) # leave StringInput do the real rendering
      input += template.content_tag :span, class: 'input-group-addon' do
        template.content_tag :i, ''
      end
      input
    end
  end

  def input_html_classes
    super.push '' # 'form-control'
  end
end
