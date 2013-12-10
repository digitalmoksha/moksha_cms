require 'spec_helper'
require 'cgi'

describe DmEvent do
  require "money-rails/test_helpers"
  include MoneyRails::TestHelpers

  describe "workshop_prices" do
    
    before do
      Account.current = FactoryGirl.create(:account)
      @workshop = FactoryGirl.create(:workshop, account_id: Account.current)
    end

    #------------------------------------------------------------------------------
    it "has account loaded" do
      expect(Account.current.account_prefix).to eq('test')
    end

    #------------------------------------------------------------------------------
    it "has a price" do
      money = Money.new(11000, @workshop.base_currency)
      price = WorkshopPrice.new(price_cents: 11000, workshop_id: @workshop, price_currency: @workshop.base_currency)
      price.save
      pp price
      pp @workshop
      expect(price.price).to eq(money)
      puts price.price.format
      monetize(:price_cents).with_currency(:gbp).should be_true
      
    end
  end
end