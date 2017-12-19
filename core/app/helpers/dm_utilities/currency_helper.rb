# Currency helper routines
#------------------------------------------------------------------------------
module DmUtilities::CurrencyHelper
  include ActionView::Helpers::NumberHelper

  # Takes a number and a country code and formats it as a monetary value
  # TODO see if there is a better way to hook in the Globalize::Currency object
  # TODO we're not using the country object right now - I think this is a problem
  #------------------------------------------------------------------------------
  def ut_currency(amount, country, options = {})
    return "&mdash;".html_safe if amount.blank?
    precision = options[:precision] || 2
    number_to_currency(amount, :locale => country.locale, :precision => precision)
  end

  # Takes a number and a country code and formats it as a monetary value
  #------------------------------------------------------------------------------
  def ut_currency_cents(cents, country, options = {})
    return "&mdash;".html_safe if cents.blank?
    ut_currency(cents/100, country, options)
  end


end