require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe Registration, :type => :model do
  setup_account

  context 'RegistrationPricingPolicy' do
    let(:workshop)   { create(:workshop_with_price) }
    let(:workshop_r) { create(:workshop_with_recurring_price) }

    describe '#payment_owed' do
      #------------------------------------------------------------------------------
      it "full payment" do
        registration = create :registration, workshop: workshop
        expect(registration.payment_owed).to eq Money.new(50000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "full payment with discount" do
        registration = create :registration, workshop: workshop, discount_value: 50, discount_use_percent: true
        expect(registration.payment_owed).to eq Money.new(25000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "with partial payment" do
        registration = create :registration, workshop: workshop, amount_paid_cents: 20000
        expect(registration.payment_owed).to eq Money.new(30000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "with partial payment with discount" do
        registration = create :registration, workshop: workshop, amount_paid_cents: 20000, discount_value: 50, discount_use_percent: true
        expect(registration.payment_owed).to eq Money.new(5000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "first recurring payment" do
        registration = create :registration, workshop: workshop_r
        expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "recurring payment with initial partial payment" do
        registration = create :registration, workshop: workshop_r, amount_paid_cents: 20000
        expect(registration.payment_owed).to eq Money.new(0, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "recurring payment with two payments made" do
        registration = create :registration, workshop: workshop_r, created_at: 55.days.ago, amount_paid_cents: 20000
        expect(registration.payment_owed).to eq Money.new(0, 'EUR')

        registration = create :registration, workshop: workshop_r, created_at: 65.days.ago, amount_paid_cents: 20000
        expect(registration.payment_owed).to eq Money.new(10000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "recurring payment with no payments made" do
        registration = create :registration, workshop: workshop_r, created_at: 55.days.ago
        expect(registration.payment_owed).to eq Money.new(20000, 'EUR')

        registration = create :registration, workshop: workshop_r, created_at: 65.days.ago
        expect(registration.payment_owed).to eq Money.new(30000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "recurring payment with mostly paid" do
        registration = create :registration, workshop: workshop_r, created_at: 130.days.ago, amount_paid_cents: 45000
        expect(registration.payment_owed).to eq Money.new(5000, 'EUR')
      end

      #------------------------------------------------------------------------------
      it "discounted recurring payment with partial payment" do
        registration = create :registration, workshop: workshop_r, discount_value: 50, discount_use_percent: true
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

    describe '#initial_payments_should_start_on' do
      it 'starts as soon as the registration is created' do
        expect(workshop.initial_payment_required_on).to be_nil
        registration = create :registration, workshop: workshop
        expect(registration.initial_payments_should_start_on).to eq registration.created_at
      end

      it 'starts on the hold date' do
        registration = create :registration, workshop: workshop, payment_reminder_hold_until: 10.days.from_now
        expect(registration.initial_payments_should_start_on).to eq 10.days.from_now.to_date
      end

      it 'starts on the hold date even if workshop date is set' do
        workshop.initial_payment_required_on = 2.days.from_now
        registration = create :registration, workshop: workshop, payment_reminder_hold_until: 10.days.from_now
        expect(registration.initial_payments_should_start_on).to eq 10.days.from_now.to_date
      end

      it 'starts on the hold date of the workshop' do
        workshop.initial_payment_required_on = 2.days.from_now
        registration = create :registration, workshop: workshop
        expect(registration.initial_payments_should_start_on).to eq 2.days.from_now.to_date
      end
    end

    describe 'writeoff' do
      #------------------------------------------------------------------------------
      it '#check_if_writeoff!' do
        registration = create :registration, workshop: workshop
        expect(registration.writtenoff_on).to eq nil

        registration = create :registration, workshop: workshop, created_at: 92.days.ago
        registration.check_if_writeoff!
        expect(registration.writtenoff_on).not_to eq nil

        registration = create :registration, workshop: workshop, created_at: 80.days.ago
        registration.check_if_writeoff!
        expect(registration.writtenoff_on).to eq nil
      end

      #------------------------------------------------------------------------------
      it '#check_if_writeoff! with recurring' do
        registration = create :registration, workshop: workshop_r
        expect(registration.writtenoff_on).to eq nil

        registration = create :registration, workshop: workshop_r, created_at: (122 + Registration::WRITE_OFF_DAYS).days.ago
        registration.check_if_writeoff!
        expect(registration.writtenoff_on).not_to eq nil

        registration = create :registration, workshop: workshop_r, created_at: (110 + Registration::WRITE_OFF_DAYS).days.ago
        registration.check_if_writeoff!
        expect(registration.writtenoff_on).to eq nil
      end
    end
  end
end
