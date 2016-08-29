# Pulled from the EasyGlobalize3Accessors gem.  It's very simple, and pulling
# here removes a dependency on a forked gem version:
# git://github.com/digitalmoksha/easy_globalize3_accessors.git
#
#------------------------------------------------------------------------------
# Definition like this:
# 
#   class Product
#     translates :title, :description
#     globalize_accessors :locales => [:en, :pl], :attributes => [:title]
#   end
# 
# Gives you access to methods: title_pl, title_en, title_pl=, title_en= (and similar 
# set of description_* methods). And they work seamlessly with Globalize3 
# (not even touching the "core" title, title= methods used by Globalize3 itself).
# 
# :locales and :attributes are optional. Default values are:
#   :locales => I18n.available_locales
#   :attributes => translated_attribute_names
# 
# which means that skipping all options will generate you accessor method for all 
# translated fields and available languages
#------------------------------------------------------------------------------
module EasyGlobalizeAccessors

  #------------------------------------------------------------------------------
  def globalize_accessors(options = {})
    options.reverse_merge!(:locales => I18n.available_locales, :attributes => translated_attribute_names)
    each_attribute_and_locale(options) do |attr_name, locale|
      define_accessors(attr_name, locale)
    end
  end

private

  #------------------------------------------------------------------------------
  def define_accessors(attr_name, locale)
    define_getter(attr_name, locale)
    define_setter(attr_name, locale)
  end
  
  #------------------------------------------------------------------------------
  def define_getter(attr_name, locale)
    define_method :"#{attr_name}_#{locale}" do
      read_attribute(attr_name, :locale => locale)
    end
  end

  #------------------------------------------------------------------------------
  def define_setter(attr_name, locale)
    define_method :"#{attr_name}_#{locale}=" do |value|
      write_attribute(attr_name, value, :locale => locale)
    end
  end

  #------------------------------------------------------------------------------
  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

end

ActiveRecord::Base.extend EasyGlobalizeAccessors
