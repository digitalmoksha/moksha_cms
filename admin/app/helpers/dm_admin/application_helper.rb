include DmAdmin::Bootstrap3Helper
include AdminTheme::MenuHelper
include AdminTheme::ThemeHelper
module DmAdmin

  VerticalFormWrapperMappings = {
    check_boxes:    :bs3_vertical_radio_and_checkboxes,
    radio_buttons:  :bs3_vertical_radio_and_checkboxes,
    file:           :bs3_vertical_file_input,
    boolean:        :bs3_vertical_boolean
  }.freeze

  FormWrapperMappings = {
    check_boxes:    :bs3_horizontal_radio_and_checkboxes,
    radio_buttons:  :bs3_horizontal_radio_and_checkboxes,
    file:           :bs3_horizontal_file_input,
    boolean:        :bs3_horizontal_boolean
  }.freeze

  module ApplicationHelper
    
    #------------------------------------------------------------------------------
    def flag_image(locale = I18n.locale, options = {})
      image_tag("dm_admin/flags/#{locale}.gif", options)
    end

  end
end
