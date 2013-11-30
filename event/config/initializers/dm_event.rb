require 'dm_event/model_decorators'

ActiveMerchant::Billing::Base.mode = :test unless Rails.env.production?
