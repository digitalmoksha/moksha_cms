Money.locale_backend = :i18n

# The money gem 7.0 and above changed the default to `ROUND_HALF_UP`
# Keep it as is for now
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
