# Validate whether an attribute has a parsable liquid template.
# if { locales: true } is passed in, will assume it's a localized
# field and check all locales
#   validates    :content, :liquid => { :locales => true }
#------------------------------------------------------------------------------
class LiquidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if options[:locales]
      Account.current.site_locales.each do |locale|
        attribute_locale = "#{attribute.to_s}_#{locale}"
        begin
          Liquid::Template.parse(record.send(attribute_locale))
        rescue Liquid::SyntaxError => e
          record.errors.add attribute_locale, e.message
        end
      end
    else
      begin
        Liquid::Template.parse(value)
      rescue Liquid::SyntaxError => e
        record.errors.add attribute, e.message
      end
    end
  end
end

