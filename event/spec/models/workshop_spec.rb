require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe Workshop, :type => :model do
  setup_account

  it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  it { is_expected.to validate_length_of(:contact_email).is_at_most(60) }
  it { is_expected.to validate_length_of(:contact_phone).is_at_most(20) }
  it { is_expected.to validate_length_of(:info_url).is_at_most(255) }
  it { is_expected.to validate_length_of(:event_style).is_at_most(255) }
  it { is_expected.to validate_length_of(:image).is_at_most(255) }
  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }

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