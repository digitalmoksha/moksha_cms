#------------------------------------------------------------------------------
class Ultracart::Notification
  attr_accessor :order_details, :items, :anchor_ids

  CURRENT_STAGE_MAPPING = { 'PO' => :pre_order, 'AR' => :account_receivable, 
                            'SD' => :shipping, 'REJ' => :rejected, 
                            'CO' => :completed_order}
  
  #------------------------------------------------------------------------------
  def initialize(notify_params)

    #--- extract the order details and the items
    @order_details  = (notify_params['export']['order'])
    @items          = @order_details['item']
    @items = Array.[](@items) if @items.class == HashWithIndifferentAccess or @items.class == Hash
    
    #--- remove the items hash from the order, so we can save the order details seperate
    @order_details.delete('item')
    
    #--- build up the anchor_ids array
    @anchor_ids = Array.new
    @items.each do |item|
      @anchor_ids << extract_anchor_id(item)        
    end
  end
  
  # Stage that the order is in
  #------------------------------------------------------------------------------
  def current_stage
    return CURRENT_STAGE_MAPPING[@order_details['current_stage']]
  end


protected
  
  #------------------------------------------------------------------------------
  def extract_anchor_id(item)
    anchor = nil
    option_items = item['option']
    option_items = Array.[](option_items) if option_items.class == Hash or option_items.class == HashWithIndifferentAccess
    unless option_items.nil? 
      option_items.each do |the_option| 
        #if the_option['option_name'] == 'anchor_id'
          anchor = the_option['option_value'] unless the_option['option_value'].blank?
        #end
      end
    end
    return anchor
  end
end

# # This function is called by UltraCart when an item is purchased from the online
# # store.  The entire order is sent.  Initially, we will look for the 
# # registration code we place in a ticket order, and mark the appropriate record
# # as payed in the database.  But this also sets up the possibility of keeping
# # our own purchase records and doing our own reporting.
# #------------------------------------------------------------------------------
# def self.verify_payment(current_account, params)
#   #--- the specifics for order have already been parsed into the params block
#   notify  = Ultracart::Notification.new(params)
#   @@uclogger.info(Time.now.utc.to_s + ": Order ID => #{notify.order_details['order_id']}  " +
#                   "Stage => #{notify.order_details['current_stage']} " +
#                   "Name => #{notify.order_details['bill_to_first_name']} #{notify.order_details['bill_to_last_name']}"
#                   )
# 
#   receipts      = Array.new
# 
#   #--- validate the merchant id
#   if notify.order_details['merchant_id'] != current_account.preferred(:ultracart_merchant_id)
#     @@uclogger.info("  ==> Error: merchant_id incorrect: #{notify.order_details['merchant_id']} != #{current_account.preferred(:ultracart_merchant_id)}")
#     @@uclogger.info(params.inspect)
#   else
#     case notify.current_stage
#     when :pre_order, :account_receivable, :shipping, :rejected
#       @@uclogger.info("  Ignored")
#       #--- these are just notifications - do nothing
#     when :completed_order
#       #--- iterate over each item in order
#       notify.items.each_with_index do |item, i|
#         #--- only record notifications that have a registration code
#         unless notify.anchor_ids[i].blank?
#           history = PaymentHistory.create(:notify => notify, :item => item, :anchor_id => notify.anchor_ids[i])
#           history.update_attribute(:total_cents, EventPayment.payment_total_cents(history.cost, history.quantity, history.discount))
#           history.update_attribute(:owner_type, 'EventRegistration')
#           history.update_attribute(:owner_id, EventRegistration.receiptcode_to_id(history.anchor_id))
#           @@uclogger.info("  item_id => #{history.item_id}  anchor_id => #{history.anchor_id}")
# 
#           if history.anchor_id
#             #--- check if there is a valid user
#             event = EventRegistration.find_by_receiptcode(history.anchor_id)
#             if event.nil?
#               @@uclogger.info("  ==> Error: invalid registration id => #{history.anchor_id}")
#               @@uclogger.info(params.inspect)
#             else
#               history.update_attribute(:currency_country_id, event.event_payment.country_id) 
#               event.mark_paid(history.total_cents)
#               event.add_comment(Comment.new(:comment => "[coupon_code: #{history.coupon_code}] ")) unless history.coupon_code.blank?
#               receipts << {:receiptcode => history.anchor_id, :cost_cents => history.total_cents, :description => history.item_name}
#             end
#           end
#         end
#       end
#     end
#   end
# 
#   return receipts
# end
