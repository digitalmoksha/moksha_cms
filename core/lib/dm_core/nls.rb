
#------------------------------------------------------------------------------
module Nls

  CONTINENTS = ['Europe', 'North America', 'South America', 'Oceania', 'Asia', 'Africa', 'Antartica']

  # default scope the msg lookup to the current theme
  #------------------------------------------------------------------------------
  def nls(message_key, options = {})
    #--- look up message in the scope of current theme, fallback to parent theme
    key       = "#{Account.current.current_theme}.#{message_key.to_s}"
    fallback  = Account.current.parent_theme ? "#{Account.current.parent_theme}.#{message_key.to_s}" : "translation missing: #{key}"
    I18n.t(key, options.merge(default: fallback.to_sym))
  end

  # Check if the message exists
  #------------------------------------------------------------------------------
  def nls?(message_key)
    key       = "#{Account.current.current_theme}.#{message_key.to_s}"
    I18n.t key, :raise => true rescue false
  end

  # Helper to generate the image_tag for a language flag.
  #  nls_flag_image(:en)
  #------------------------------------------------------------------------------
  def nls_flag_image(lang = nil)
    image_tag(DmCore::Language.flag_image(lang))
  end

end

