
#------------------------------------------------------------------------------
module Nls
  
  CONTINENTS = ['Europe', 'North America', 'South America', 'Oceania', 'Asia', 'Africa', 'Antartica']
  
  # default scope the msg lookup to the current theme
  #------------------------------------------------------------------------------
  def nls(message_key, options = {})
    if options.empty?
      #--- look up message in the scope of current theme, fallback to parent theme
      key       = "#{Account.current.current_theme}.#{message_key.to_s}"
      fallback  = "#{Account.current.parent_theme}.#{message_key.to_s}" if Account.current.parent_theme
      I18n.t(key, default: fallback.to_sym).html_safe      
    else
      #--- options specified, pass it all through
      I18n.t(message_key, options).html_safe
    end
  end

  # Helper to generate the image_tag for a language flag.  
  #  nls_flag_image(:en)
  #------------------------------------------------------------------------------
  def nls_flag_image(lang = nil)
    image_tag(DmCore::Language.flag_image(lang))
  end

end

