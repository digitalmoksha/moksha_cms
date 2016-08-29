#------------------------------------------------------------------------------
class DmCore::Language < ActiveRecord::Base # :nodoc:

  self.table_name = "globalize_languages"

  # Given the short name of a language, get the associated language object
  # If it doesn't exist, return the default language
  #------------------------------------------------------------------------------
  def self.get_language(locale, default_locale = DmCore.config.default_locale)
    self.find_by_iso_639_1(locale) || get_language(default_locale, default_locale)
  end

  # get the current locale
  #------------------------------------------------------------------------------
  def self.locale
    I18n.locale
  end
  
  #------------------------------------------------------------------------------
  def self.locale=(locale = DmCore.config.default_locale)
    I18n.locale = locale
  end
  
  # [todo] don't know if this is needed anymore
  #------------------------------------------------------------------------------
  def self.languages
    DmCore.config.locales
  end
  
  # [todo] don't know if this is needed anymore
  #------------------------------------------------------------------------------
  def self.language_array
    DmCore.config.locales
  end
  
  #------------------------------------------------------------------------------
  def self.current_language_name
    self.get_language(self.locale).english_name
  end

  #  flag_image(:en)
  #------------------------------------------------------------------------------
  def self.flag_image(locale)
    locale.nil? ? "dm_core/flags/#{I18n.locale}.gif" : "dm_core/flags/#{locale}.gif"
  end
  
  # Given a url, change it to the requested locale.  Assumes that locale is embedded
  # in the url as /:locale/  (.../en/teaching, etc).  Originaly tried to use a named
  # route, like showpage_url(:locale => 'ja'), but it doesn't work in some cases
  #------------------------------------------------------------------------------
  def self.translate_url(url, locale)
    return url.sub("/#{self.locale.to_s}/", "/#{locale.to_s}/")
  end
  
  #------------------------------------------------------------------------------
  def locale
    self.iso_639_1
  end
end
