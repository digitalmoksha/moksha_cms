module DmCore
  module ParamsHelper
    # given a "width" parameter, make it into a valid css width value
    #------------------------------------------------------------------------------
    def css_style_width(width = '')
      width = width.to_s.as_css_size
      width.blank? ? '' : "width:#{width};"
    end

    # given a "height" parameter, make it into a valid css height value
    #------------------------------------------------------------------------------
    def css_style_height(height = '')
      height = height.to_s.as_css_size
      height.blank? ? '' : "height:#{height};"
    end
  end
end
