class DmEvent::Admin::WorkshopPricesController < DmEvent::Admin::AdminController
  include DmEvent::PermittedParams

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
    attributes = WorkshopPrice.prepare_prices(workshop_price_params.merge(price_currency: @workshop.base_currency))
    @workshop_price = @workshop.workshop_prices.new(attributes)
    if @workshop_price.save
      redirect_to admin_workshop_workshop_prices_url(@workshop), notice: 'Price was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    attributes = WorkshopPrice.prepare_prices(workshop_price_params.merge(price_currency: @workshop.base_currency))
    if @workshop_price.update_attributes(attributes)
      redirect_to admin_workshop_workshop_prices_url(@workshop), notice: 'Price was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    if @workshop_price.registrations.count == 0
      @workshop_price.destroy
      redirect_to admin_workshop_workshop_prices_url(@workshop), notice: 'Price was successfully deleted.'
    else
      redirect_to admin_workshop_workshop_prices_url(@workshop), error: 'Registrations are using this price - unable to delete'
    end
  end

  #------------------------------------------------------------------------------
  def sort
    @workshop_price.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    render nothing: true
  end

private

  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop = Workshop.friendly.find(params[:workshop_id])
  end
  
  #------------------------------------------------------------------------------
  def price_lookup
    @workshop_price = WorkshopPrice.find(params[:id])
    @workshop       = @workshop_price.workshop
  end

end
