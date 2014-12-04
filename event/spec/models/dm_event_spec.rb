require 'rails_helper'

describe DmEvent do
  setup_account
  
  describe "workshop_prices" do
    
    before :each do
      DmCore.config.locales = [:en, :de]
      @workshop = FactoryGirl.create(:workshop)
    end

    #------------------------------------------------------------------------------
    it "has account loaded" do
      expect(Account.current.account_prefix).to eq('test')
    end

    #------------------------------------------------------------------------------
    it "sets price correctly" do
      #--- demonstrate that WorkshopPrice initializes with incorrect currency by default
      workshop_price = @workshop.workshop_prices.new('price' => '11000', 'price_currency' => 'JPY')
      expect(workshop_price.price).not_to eq(Money.new(11000, 'JPY'))

      attributes = WorkshopPrice.prepare_prices('price' => '11000', 'price_currency' => 'JPY',
                                                'alt1_price' => '500', 'alt1_price_currency' => 'EUR',
                                                'alt2_price' => '30000', 'alt2_price_currency' => 'USD')
      workshop_price = @workshop.workshop_prices.new(attributes)
      expect(workshop_price.price).to       eq(Money.new(11000, 'JPY'))
      expect(workshop_price.alt1_price).to  eq(Money.new(50000, 'EUR'))
      expect(workshop_price.alt2_price).to  eq(Money.new(3000000, 'USD'))
    end
  end
end