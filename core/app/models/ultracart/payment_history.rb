# Integration with the Ultracart shopping cart (ultracart.com)
#------------------------------------------------------------------------------
class Ultracart::PaymentHistory < PaymentHistory

  # Params: :notify, :item, :anchor_id
  #------------------------------------------------------------------------------
  def initialize(params, options)
    init_params = Hash.new
    notify      = params[:notify]
    item        = params[:item]
    anchor_id   = params[:anchor_id]

    #--- extract the relevant data
    init_params[:order_ref]       = notify.order_details['order_id']
    init_params[:payment_method]  = notify.order_details['payment_method']
    init_params[:payment_date]    = Time.parse(notify.order_details['payment_date_time']).utc unless notify.order_details['payment_date_time'].nil?
    init_params[:bill_to_name]    = notify.order_details['bill_to_first_name'] + ' ' + notify.order_details['bill_to_last_name']
    init_params[:current_stage]   = notify.current_stage.to_s
    init_params[:order_details]   = notify.order_details
    init_params[:item_details]    = item
    if item
      init_params[:item_ref]      = item['item_id']
      init_params[:cost]          = item['cost']
      init_params[:discount]      = item['discount']
      init_params[:quantity]      = item['quantity'].to_i
      init_params[:item_name]     = item['description']
      init_params[:anchor_id]     = PaymentHistory.extract_anchor_id(anchor_id) unless anchor_id.blank?
    end
    super(init_params, options)
  end

  #------------------------------------------------------------------------------
  def get_option_value(name)
    value         = nil
    option_items  = item_details['option']
    option_items  = Array.[](option_items) if option_items.class == Hash or option_items.class == HashWithIndifferentAccess
    unless option_items.nil?
      option_items.each do |the_option|
        if the_option['option_name'] == name
          value = the_option['option_value'] unless the_option['option_value'].blank?
        end
      end
    end
    return value
  end

  #------------------------------------------------------------------------------
  def coupon_code
    if order_details.nil? or order_details['coupon'].nil?
      ''
    else
      order_details['coupon']['coupon_code']
    end
  end
end