require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe WorkshopPrice, :type => :model do
  setup_account

  describe "workshop_prices" do
    #------------------------------------------------------------------------------
    it "creates price correctly" do
      attributes = WorkshopPrice.prepare_prices('price' => '11000', 'price_currency' => 'JPY',
                                                'alt1_price' => '500', 'alt1_price_currency' => 'EUR',
                                                'alt2_price' => '30000', 'alt2_price_currency' => 'USD')
      workshop_price = WorkshopPrice.new(attributes)
      expect(workshop_price.price).to       eq(Money.new(11000, 'JPY'))
      expect(workshop_price.alt1_price).to  eq(Money.new(50000, 'EUR'))
      expect(workshop_price.alt2_price).to  eq(Money.new(3000000, 'USD'))
    end

    #------------------------------------------------------------------------------
    it 'can be sold out' do
      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'))
      expect(workshop_price.total_available).to eq(nil)
      expect(workshop_price.sold_out?(1)).to eq false

      workshop_price.total_available = 0
      expect(workshop_price.sold_out?(1)).to eq true

      workshop_price.total_available = 10
      expect(workshop_price.sold_out?(1)).to eq false
      expect(workshop_price.sold_out?(10)).to eq true
    end

    describe '#visible?' do
      #------------------------------------------------------------------------------
      it 'is has not time limits' do
        workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'))
        expect(workshop_price.visible?).to eq true
      end

      #------------------------------------------------------------------------------
      it 'should not be visible yet' do
        workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'), valid_starting_on: 1.day.from_now, valid_until: 2.days.from_now)
        expect(workshop_price.visible?).to eq false
      end

      #------------------------------------------------------------------------------
      it 'should be visible within this period' do
        workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'), valid_starting_on: 1.day.ago, valid_until: 2.days.from_now)
        expect(workshop_price.visible?).to eq true
      end

      #------------------------------------------------------------------------------
      it 'should not be visible after period' do
        workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'), valid_starting_on: 3.days.ago, valid_until: 1.day.ago)
        expect(workshop_price.visible?).to eq false
      end
    end

    #------------------------------------------------------------------------------
    it 'should format price correctly' do
      workshop_price = WorkshopPrice.new(price: Money.new(534, 'USD'))
      expect(workshop_price.price_formatted).to eq '$5.34'

      workshop_price.price = nil
      expect(workshop_price.price_formatted).to eq ''

      workshop_price.price = Money.new(534, 'JPY')
      expect(workshop_price.price_formatted).to eq '¥534'
    end

    #------------------------------------------------------------------------------
    it 'has recurring payments' do
      workshop_price = WorkshopPrice.new(price: Money.new(534, 'USD'))
      expect(workshop_price.recurring_payments?).to eq false
      workshop_price.recurring_number = 3
      expect(workshop_price.recurring_payments?).to eq true
    end

    #------------------------------------------------------------------------------
    it 'returns the amount to be paid for each payment' do
      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'))
      expect(workshop_price.payment_price).to eq Money.new(500, 'USD')

      workshop_price.recurring_number = 2
      expect(workshop_price.payment_price).to eq Money.new(250, 'USD')
    end

    #------------------------------------------------------------------------------
    it 'returns list of currencies in use' do
      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'), alt1_price: Money.new(466, 'EUR'), alt2_price: Money.new(570, 'JPY'))
      expect(workshop_price.currency_list).to eq [['USD', 'USD'], ['EUR', 'EUR'], ['JPY', 'JPY']]
    end

    #------------------------------------------------------------------------------
    it 'takes an amount in one alternate currency and returns value in base currency' do
      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'), alt1_price: Money.new(466, 'EUR'), alt2_price: Money.new(570, 'JPY'))
      expect(workshop_price.to_base_currency(Money.new(250, 'USD'))).to   eq Money.new(250, 'USD')
      expect(workshop_price.to_base_currency(Money.new(233, 'EUR'))).to   eq Money.new(250, 'USD')
      expect(workshop_price.to_base_currency(Money.new(285, 'JPY'))).to   eq Money.new(250, 'USD')

      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'))
      expect(workshop_price.to_base_currency(Money.new(250, 'USD'))).to eq Money.new(250, 'USD')
    end

    #------------------------------------------------------------------------------
    it 'has a one day payment schedule for non-recurring' do
      workshop_price  = WorkshopPrice.new(price: Money.new(500, 'USD'))
      start_day       = 3.days.ago.to_date
      expect(workshop_price.payment_schedule).to eq [{ due_on: 0, period_payment: Money.new(500, 'USD'), total_due: Money.new(500, 'USD') }]
      expect(workshop_price.payment_schedule(start_day)).to eq [{ due_on: start_day, period_payment: Money.new(500, 'USD'), total_due: Money.new(500, 'USD') }]

      workshop_price.recurring_number = 3
      workshop_price.recurring_period = 30
      expect(workshop_price.payment_schedule).to eq [
        { due_on: 0,  period_payment: Money.new(167, 'USD'), total_due: Money.new(167, 'USD') },
        { due_on: 30, period_payment: Money.new(167, 'USD'), total_due: Money.new(334, 'USD') },
        { due_on: 60, period_payment: Money.new(166, 'USD'), total_due: Money.new(500, 'USD') }
      ]

      expect(workshop_price.payment_schedule(start_day)).to eq [
        { due_on: start_day,           period_payment: Money.new(167, 'USD'), total_due: Money.new(167, 'USD') },
        { due_on: start_day + 30.days, period_payment: Money.new(167, 'USD'), total_due: Money.new(334, 'USD') },
        { due_on: start_day + 60.days, period_payment: Money.new(166, 'USD'), total_due: Money.new(500, 'USD') }
      ]
    end

    #------------------------------------------------------------------------------
    it 'returns the scheudled payment entry for a date' do
      workshop_price  = WorkshopPrice.new(price: Money.new(500, 'USD'), recurring_number: 3, recurring_period: 30)
      start_day       = 3.days.ago.to_date
      expect(workshop_price.specific_payment_schedule(Time.now, Time.now.to_date)).to eq({ due_on: Time.now.to_date, period_payment: Money.new(167, 'USD'), total_due: Money.new(167, 'USD') })
      expect(workshop_price.specific_payment_schedule(start_day, 5.days.from_now)).to eq({ due_on: start_day, period_payment: Money.new(167, 'USD'), total_due: Money.new(167, 'USD') })
      expect(workshop_price.specific_payment_schedule(start_day, 95.days.from_now)).to eq({ due_on: start_day + 60.days, period_payment: Money.new(166, 'USD'), total_due: Money.new(500, 'USD') })
    end

    #------------------------------------------------------------------------------
    it 'return the last scheduled payment date' do
      workshop_price  = WorkshopPrice.new(price: Money.new(500, 'USD'), recurring_number: 3, recurring_period: 30)
      start_day       = Time.now.to_date
      expect(workshop_price.last_scheduled_payment_date(start_day)).to eq (start_day + 60.days)

      workshop_price = WorkshopPrice.new(price: Money.new(500, 'USD'))
      expect(workshop_price.last_scheduled_payment_date(start_day)).to eq start_day
    end
  end
end