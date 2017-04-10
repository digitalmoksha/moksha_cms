require 'spec_helper'
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
    it "recurring payment with initial partial payment" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, amount_paid_cents: 20000
      expect(registration.payment_owed).to eq Money.new(0, 'EUR')
    end

    #------------------------------------------------------------------------------
    it "recurring payment with two payments made" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, created_at: 55.days.ago, amount_paid_cents: 20000
      expect(registration.payment_owed).to eq Money.new(0, 'EUR')

      registration = create :registration, workshop: workshop, created_at: 65.days.ago, amount_paid_cents: 20000
      expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
    end

    #------------------------------------------------------------------------------
    it "recurring payment with no payments made" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, created_at: 55.days.ago
      expect(registration.payment_owed).to eq Money.new(20000, 'EUR')

      registration = create :registration, workshop: workshop, created_at: 65.days.ago
      expect(registration.payment_owed).to eq Money.new(30000, 'EUR')
    end

    #------------------------------------------------------------------------------
    it "recurring payment with mostly paid" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, created_at: 130.days.ago, amount_paid_cents: 45000
      expect(registration.payment_owed).to eq Money.new(5000, 'EUR')
    end

    #------------------------------------------------------------------------------
    it "discounted recurring payment with partial payment" do
      workshop = create :workshop_with_recurring_price
      registration = create :registration, workshop: workshop, discount_value: 50, discount_use_percent: true
      expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
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
    expect(registration.past_due?).to eq false

    registration  = create :registration, workshop: workshop, created_at: 8.days.ago
    expect(registration.past_due?).to eq true

    registration  = create :registration, workshop: workshop, created_at: 25.days.ago, amount_paid_cents: 10000
    expect(registration.past_due?).to eq false
  end
  
  describe '#payment_reminder_due?' do
    #------------------------------------------------------------------------------
    it 'non-recurring payment reminder due after 7 day grace period' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 6.days.ago
      expect(registration.payment_reminder_due?).to eq false

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago
      expect(registration.payment_reminder_due?).to eq true

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago, amount_paid_cents: 5000
      expect(registration.payment_reminder_due?).to eq true
    end

    #------------------------------------------------------------------------------
    it 'non-recurring payment reminder due after 14 days last reminder sent' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 10.days.ago
      registration.payment_reminder_sent_on = nil
      expect(registration.payment_reminder_due?).to eq true

      registration  = create :registration, workshop: workshop, created_at: 30.days.ago
      registration.payment_reminder_sent_on = 10.days.ago
      expect(registration.payment_reminder_due?).to eq false
      registration.payment_reminder_sent_on = 14.days.ago
      expect(registration.payment_reminder_due?).to eq true
    end

    #------------------------------------------------------------------------------
    it 'payment reminder respects preferred_payment_reminder_hold_until' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 30.days.ago
      registration.preferred_payment_reminder_hold_until = 10.days.from_now
      registration.payment_reminder_sent_on = 20.days.ago
      expect(registration.payment_reminder_due?).to eq false

      registration.preferred_payment_reminder_hold_until = 2.days.ago
      expect(registration.payment_reminder_due?).to eq true
    end

    #------------------------------------------------------------------------------
    it 'recurring payment reminder due after 7 day grace period' do
      workshop      = create :workshop_with_recurring_price
      registration  = create :registration, workshop: workshop, created_at: 6.days.ago
      expect(registration.payment_reminder_due?).to eq false

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago
      expect(registration.payment_reminder_due?).to eq true

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago, amount_paid_cents: 5000
      expect(registration.payment_reminder_due?).to eq true
    end

    #------------------------------------------------------------------------------
    it 'recurring payment reminder due at 3rd payment and 7 day grace period' do
      workshop      = create :workshop_with_recurring_price
      registration  = create :registration, workshop: workshop, created_at: 65.days.ago, amount_paid_cents: 20000
      expect(registration.payment_reminder_due?).to eq false

      registration  = create :registration, workshop: workshop, created_at: 70.days.ago, amount_paid_cents: 20000
      expect(registration.payment_reminder_due?).to eq true
    end
  end
end
