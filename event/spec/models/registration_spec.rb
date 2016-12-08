require 'rails_helper'
DmCore.config.locales = [:en, :de]

describe Registration, :type => :model do
  setup_account

  describe '#payment_owed' do
  
    let(:workshop) { create(:workshop) }

    #------------------------------------------------------------------------------
    it "full payment" do
      workshop = create :workshop_with_price
      registration = create :registration, workshop: workshop
      expect(registration.payment_owed).to eq Money.new(50000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "full payment with discount" do
      workshop = create :workshop_with_price
      registration = create :registration, workshop: workshop, discount_value: 50, discount_use_percent: true
      expect(registration.payment_owed).to eq Money.new(25000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "with partial payment" do
      workshop = create :workshop_with_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 20000
      expect(registration.payment_owed).to eq Money.new(30000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "with partial payment with discount" do
      workshop = create :workshop_with_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 20000, discount_value: 50, discount_use_percent: true
      expect(registration.payment_owed).to eq Money.new(5000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "first recurring payment" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop
      expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "recurring payment with partial payment" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 20000
      expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "recurring payment with mostly paid" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 45000
      expect(registration.payment_owed).to eq Money.new(5000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "discounted recurring payment with partial payment" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, discount_value: 50, discount_use_percent: true
      expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "pay remaining amount if within 20 EUR" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 39000
      expect(registration.payment_owed).to eq Money.new(11000, 'EUR')
    end
    
    #------------------------------------------------------------------------------
    it "pay 0 if no workshop prices" do
      workshop = create :workshop
      registration = create :registration, workshop: workshop
      expect(workshop.workshop_prices.empty?).to be true
      expect(registration.payment_owed).to eq Money.new(0, 'EUR')
    end
  end
  
  #------------------------------------------------------------------------------
  it 'knows if a non-recurring payment is past due' do
    workshop      = create :workshop_with_price
    registration  = create :registration, workshop: workshop, created_at: 3.days.ago
    expect(registration.past_due?).to eq false

    registration  = create :registration, workshop: workshop, created_at: 8.days.ago
    expect(registration.past_due?).to eq true

    registration  = create :registration, workshop: workshop, created_at: Time.now
    expect(registration.past_due?).to eq false
    
    registration  = create :registration, workshop: workshop, created_at: 8.days.ago, amount_paid_cents: 10000
    expect(registration.past_due?).to eq true
  end

  #------------------------------------------------------------------------------
  it 'knows if a recurring payment is past due' do
    workshop      = create :workshop_with_recurring_price
    registration  = create :registration, workshop: workshop, created_at: 3.days.ago
    expect(registration.past_due?).to eq true
  end
end
