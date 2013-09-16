module DmCore
  module ParamsHelper

    # given a "width" parameter, make it into a valid css width value
    #------------------------------------------------------------------------------
    def css_style_width(width = '')
      width = width.to_s.as_css_size
      return width.blank? ? '' : " width:#{width};"
    end

  end
end
