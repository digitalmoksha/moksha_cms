# Validate whether the default locale of a translated attribute is present
#   validates    :content, presence_default_locale: true
#------------------------------------------------------------------------------
class PresenceDefaultLocaleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    attribute_locale = "#{attribute}_#{Account.current.preferred_default_locale}"
    record.errors.add attribute_locale, I18n.t("errors.messages.blank") if record.send(attribute_locale).blank?
  end
end
