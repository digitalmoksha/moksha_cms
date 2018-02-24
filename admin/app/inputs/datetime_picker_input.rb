# Pulled from the https://github.com/zpaulovics/datetimepicker-rails and
# http://eonasdan.github.io/bootstrap-datetimepicker
# which integrates with bootstrap-datetimepicker
#------------------------------------------------------------------------------
class DatetimePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    value = object.send(attribute_name) if object.respond_to? attribute_name
    display_pattern = I18n.t('datepicker.dformat', default: '%Y/%m/%d') + ' ' + I18n.t('timepicker.dformat', default: '%R')
    input_html_options[:value] ||= I18n.localize(value, format: display_pattern) if value.present?

    input_html_options[:type] = 'text'
    picker_pettern = I18n.t('datepicker.pformat', default: 'YYYY/MM/DD') + ' ' + I18n.t('timepicker.pformat', default: 'HH:mm')
    input_html_options[:data] ||= {}
    input_html_options[:data].merge!({ date_format: picker_pettern, date_language: I18n.locale.to_s,
                                       date_weekstart: I18n.t('datepicker.weekstart', default: 0) })

    template.content_tag :div, class: 'input-group date datetimepicker_control' do
      input  = super(wrapper_options) # leave StringInput do the real rendering
      input += template.content_tag :span, class: 'input-group-addon btn btn-default datepickerbutton' do
        template.content_tag :span, '', class: 'fa fa-calendar'
      end
      input
    end
  end

  def input_html_classes
    super.push '' # 'form-control'
  end
end
