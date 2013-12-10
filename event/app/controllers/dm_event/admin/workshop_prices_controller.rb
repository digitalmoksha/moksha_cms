class DmEvent::Admin::WorkshopPricesController < DmEvent::Admin::ApplicationController

  before_filter     :workshop_lookup, :only   => [:index, :new, :create]
  before_filter     :price_lookup,  :except => [:index, :new, :create]
  
  #------------------------------------------------------------------------------
  def index
    @workshop_prices  = @workshop.workshop_prices
  end

  #------------------------------------------------------------------------------
  def new
    @workshop_price = @workshop.workshop_prices.build(price_currency: @workshop.base_currency)
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    attributes = WorkshopPrice.prepare_prices(params[:workshop_price].merge(price_currency: @workshop.base_currency))
    @workshop_price = @workshop.workshop_prices.new(attributes)
    if @workshop_price.save
      debugger
      redirect_to admin_workshop_workshop_prices_url(@workshop), notice: 'Price was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    attributes = WorkshopPrice.prepare_prices(params[:workshop_price].merge(price_currency: @workshop.base_currency))
    if @workshop_price.update_attributes(attributes)
      redirect_to admin_workshop_workshop_prices_url(@workshop), notice: 'Price was successfully updated.'
    else
      render action: :edit
    end
  end


  # #------------------------------------------------------------------------------
  # def show
  #   @event_payment = EventPayment.find(params[:id])
  # end
  # 
  # #------------------------------------------------------------------------------
  # def new
  #   unless params[:id] == nil
  #     @event_payment = EventPayment.new
  #     @event_payment.event_workshop_id = params[:id]
  #     @workshop           = EventWorkshop.find_by_id(@event_payment.event_workshop_id)
  #   else
  #     redirect_to :controller => 'events', :action => 'list'
  #   end
  # 
  # end
  # 
  # #------------------------------------------------------------------------------
  # def create
  #   @event_payment = EventPayment.new(params[:event_payment])
  #   if @event_payment.save
  #     flash[:notice] = 'EventPayment was successfully created.'
  #     redirect_to :action => 'list', :id => @event_payment.event_workshop_id
  #   else
  #     render :action => 'new'
  #   end
  # end
  # 
  # #------------------------------------------------------------------------------
  # def edit
  #   @event_payment = EventPayment.find(params[:id])
  # end
  # 
  # #------------------------------------------------------------------------------
  # def update
  #   @event_payment = EventPayment.find(params[:id])
  #   if @event_payment.update_attributes(params[:event_payment])
  #     flash[:notice] = 'EventPayment was successfully updated.'
  #     redirect_to :action => 'list', :id => @event_payment.event_workshop_id
  #   else
  #     render :action => 'edit'
  #   end
  # end
  # 
  # #------------------------------------------------------------------------------
  # def destroy
  #   @event_payment = EventPayment.find(params[:id])
  #   #--- unlink any registrations
  #   @event_registrations = @event_payment.event_workshop.event_registration.where(:event_payment_id => @event_payment.id)
  #   @event_registrations.each { |r| r.update_attribute(:event_payment_id, nil) }
  #   @event_payment.destroy
  #   redirect_to :action => :list, :id => @event_payment.event_workshop
  # end

  #------------------------------------------------------------------------------
  def sort
    @workshop_price.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    render nothing: true
  end
  
  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop           = Workshop.find(params[:workshop_id])
  end
  
  #------------------------------------------------------------------------------
  def price_lookup
    @workshop_price = WorkshopPrice.find(params[:id])
    @workshop       = @workshop_price.workshop
  end

  # # preview
  # #------------------------------------------------------------------------------
  # def preview
  #   #--- there is an extra &_= on the end that needs to be stripped off
  #   @results = request.raw_post[0..(request.raw_post.length-2)]
  # 
  #   render :layout => false
  # end

end
