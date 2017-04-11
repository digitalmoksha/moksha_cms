class AddPaymentComment < ActiveRecord::Migration[4.2]
  def up
    add_column      :ems_registrations, :payment_comment_id,    :integer
    rename_column   :ems_registrations, :payment_comment,       :payment_comment_old
    
    Registration.unscoped.each do |r|
      Account.current = Account.find(r.account_id)
      if !r.payment_comment_old.blank?
        comment = r.private_comments.create(body: r.payment_comment_old, user_id: 1)
        r.reload.update_attribute :payment_comment_id, comment.id
      end
    end
    
    remove_column   :ems_registrations, :payment_comment_old
  end
  def down
    remove_column   :ems_registrations, :payment_comment_id
    add_column      :ems_registrations, :payment_comment,     :string
  end
end
