module DmCore
  module PaymentHistories
    class UpdateService
      include DmCore::ServiceSupport

      def initialize(payment_history, amount, user_profile, options)
        @payment_history, @amount, @user_profile, @options = payment_history, amount, user_profile, options
      end

      #------------------------------------------------------------------------------
      def call
        @payment_history.update_attributes(
          total_cents: @amount.cents,
          total_currency: @amount.currency.iso_code,
          cost: @amount.to_f,
          item_ref: @options[:item_ref],
          payment_method: @options[:payment_method],
          bill_to_name: @options[:bill_to_name],
          payment_date: @options[:payment_date],
          user_profile_id: (@user_profile ? @user_profile.id : nil)
        )
      end
    end
  end
end
