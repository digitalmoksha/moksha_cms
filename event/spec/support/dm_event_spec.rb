require 'spec_helper'
require 'cgi'

describe DmEvent do

  describe "workshop_prices" do

    before do
      Account.current = FactoryGirl.create(:account)
    end

    #------------------------------------------------------------------------------
    it "has account loaded" do
      expect(Account.current.account_prefix).to eq('test')
    end

    #------------------------------------------------------------------------------
    it "has a price" do
      price = WorkshopPrice.new(price_cents: 108)
      expect(price.price_cents).to eq(108)
    end
  end
end