module OffsitePayments
  module Integrations
  end
end

class FixPaymentHistorySerialization < ActiveRecord::Migration
  def up
    PaymentHistory.unscoped.ids.each do |id|
      data = PaymentHistory.unscoped.find(id).attributes_before_type_cast["notify_data"]
      if data && data.sub!('ActiveMerchant::Billing::Integrations', 'OffsitePayments::Integrations')
        sql = %Q{UPDATE core_payment_histories SET core_payment_histories.notify_data = #{PaymentHistory.sanitize(data)} WHERE core_payment_histories.id = #{id}}
        ApplicationRecord.connection.execute(sql)
      end
    end
  end
  
  def down
  end
end
