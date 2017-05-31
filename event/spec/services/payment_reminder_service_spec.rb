require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe PaymentReminderService, type: :service do
  setup_account

  # tests assume   REMINDER_SCHEDULE = [2, 14, 30, 60]
  describe '#payment_reminder_due?' do
    #------------------------------------------------------------------------------
    it 'non-recurring payment reminder due after 14 days' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 1.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq false

      registration  = create :registration, workshop: workshop, created_at: 15.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true
    end

    #------------------------------------------------------------------------------
    it 'non-recurring payment reminder due after 14 days last reminder sent' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 14.days.ago
      registration.payment_reminder_sent_on = nil
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: 20.days.ago
      registration.payment_reminder_sent_on = registration.created_at + 10.days
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true

      registration.payment_reminder_sent_on = registration.created_at + 15.days
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq false
    end

    #------------------------------------------------------------------------------
    it 'payment reminder respects preferred_payment_reminder_hold_until' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 30.days.ago
      registration.preferred_payment_reminder_hold_until = 10.days.from_now
      registration.payment_reminder_sent_on = 20.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq false

      registration.preferred_payment_reminder_hold_until = 2.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true
    end

    #------------------------------------------------------------------------------
    it 'recurring payment reminder due after 14 day' do
      workshop      = create :workshop_with_recurring_price
      registration  = create :registration, workshop: workshop, created_at: 1.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq false

      registration  = create :registration, workshop: workshop, created_at: 10.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: 15.days.ago, amount_paid_cents: 5000
      allow(registration).to receive(:last_payment_on).and_return(15.days.ago)
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true
    end

    #------------------------------------------------------------------------------
    it 'recurring payment reminder due at 3rd payment' do
      workshop      = create :workshop_with_recurring_price
      registration  = create :registration, workshop: workshop, created_at: 65.days.ago, amount_paid_cents: 20000
      allow(registration).to receive(:last_payment_on).and_return(registration.created_at + 60.days)
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true

      # registration  = create :registration, workshop: workshop, created_at: 70.days.ago, amount_paid_cents: 20000
      allow(registration).to receive(:last_payment_on).and_return(registration.created_at + 50.days)
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true
    end
    
    #------------------------------------------------------------------------------
    it 'handles time before or after' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: (Time.now + 2.days)
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq false

      registration  = create :registration, workshop: workshop, created_at: 80.days.ago
      expect(PaymentReminderService.payment_reminder_due?(registration)).to eq true
    end

    it 'marks a registration as a loss if beyond end of period'
  end
  
  describe '#past_due?' do

    #------------------------------------------------------------------------------
    it 'knows if a non-recurring payment is past due' do
      workshop      = create :workshop_with_price
      registration  = create :registration, workshop: workshop, created_at: 3.days.ago
      expect(PaymentReminderService.past_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago
      expect(PaymentReminderService.past_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: Time.now
      expect(PaymentReminderService.past_due?(registration)).to eq false
    
      registration  = create :registration, workshop: workshop, created_at: 8.days.ago, amount_paid_cents: 10000
      expect(PaymentReminderService.past_due?(registration)).to eq true
    end

    #------------------------------------------------------------------------------
    it 'knows if a recurring payment is past due' do
      workshop      = create :workshop_with_recurring_price
      registration  = create :registration, workshop: workshop, created_at: 3.days.ago
      expect(PaymentReminderService.past_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: 8.days.ago
      expect(PaymentReminderService.past_due?(registration)).to eq true

      registration  = create :registration, workshop: workshop, created_at: 25.days.ago, amount_paid_cents: 10000
      expect(PaymentReminderService.past_due?(registration)).to eq false
    end

  end
end
