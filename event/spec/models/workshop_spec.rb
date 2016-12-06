require 'rails_helper'
DmCore.config.locales = [:en, :de]

describe Workshop, :type => :model do
  setup_account
  
  describe "workshop_prices" do
    
    let(:workshop) { create(:workshop) }

    #------------------------------------------------------------------------------
    it "sets price correctly" do
      attributes = WorkshopPrice.prepare_prices('price' => '11000', 'price_currency' => 'JPY',
                                                'alt1_price' => '500', 'alt1_price_currency' => 'EUR',
                                                'alt2_price' => '30000', 'alt2_price_currency' => 'USD')
      workshop_price = workshop.workshop_prices.new(attributes)
      expect(workshop_price.price).to       eq(Money.new(11000, 'JPY'))
      expect(workshop_price.alt1_price).to  eq(Money.new(50000, 'EUR'))
      expect(workshop_price.alt2_price).to  eq(Money.new(3000000, 'USD'))
    end
  end
end