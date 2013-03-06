
#------------------------------------------------------------------------------
module Nls
  
  CONTINENTS = ['Europe', 'North America', 'South America', 'Oceania', 'Asia', 'Africa', 'Antartica']
  
  # default scope the msg lookup to the account_prefix
  #------------------------------------------------------------------------------
  def nls(message_key, options = {})
    options.reverse_merge!  :scope =>  Account.current.account_prefix
    I18n.t(message_key, options).html_safe
  end

  # Helper to generate the image_tag for a language flag.  
  #  nls_flag_image(:en)
  #------------------------------------------------------------------------------
  def nls_flag_image(lang = nil)
    image_tag(DmCore::Language.flag_image(lang))
  end

end

