module DmCore
  module PaymentHistories
    class CreateService
      include DmCore::ServiceSupport

      def initialize(anchor_id, amount, user_profile, options)
        @anchor_id, @amount, @user_profile, @options = anchor_id, amount, user_profile, options
      end

      #------------------------------------------------------------------------------
      def call
        PaymentHistory.create(
          anchor_id: @anchor_id,
          total_cents: @amount.cents,
          total_currency: @amount.currency.iso_code,
          item_ref: @options[:item_ref],
          cost: @amount.to_f,
          quantity: 1,
          discount: 0,
          payment_method: @options[:payment_method],
          bill_to_name: @options[:bill_to_name],
          payment_date: @options[:payment_date],
          user_profile_id: (@user_profile ? @user_profile.id : nil),
          notify_data: @options[:notify_data],
          transaction_id: @options[:transaction_id],
          status: (@user_profile ? "Completed" : @options[:status])
        )
      end
    end
  end
end