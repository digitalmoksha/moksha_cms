require 'spec_helper'

describe UserProfile, type: :model do
  setup_account

  it 'is valid with a first_name, last_name, and public_name' do
    expect(build(:user_profile)).to be_valid
  end

  it 'is invalid without a first_name' do
    record = build(:user_profile, first_name: nil)

    expect(record).not_to be_valid
    expect(record.errors[:first_name].size).to eq(1)
  end

  it 'is invalid without a last_name' do
    record = build(:user_profile, last_name: nil)

    expect(record).not_to be_valid
    expect(record.errors[:last_name].size).to eq(1)
  end

  it 'is invalid without a public name' do
    record = build(:user_profile, public_name: nil)

    expect(record).not_to be_valid
    expect(record.errors[:public_name].size).to eq(1)
  end

  it 'is invalid with a duplicate public name (case insensitive)' do
    create(:user_profile, public_name: 'joe')
    profile = build(:user_profile, public_name: 'Joe')

    expect(profile).not_to be_valid
    expect(profile.errors[:public_name].size).to eq(1)
  end

  it 'requires email, address, city, and zipcode if address_required' do
    profile = build(:user_profile, email: nil, address: nil, city: nil, zipcode: nil)
    profile.address_required = true

    expect(profile).not_to be_valid
    expect(profile.errors[:email].size).to eq(1)
    expect(profile.errors[:address].size).to eq(1)
    expect(profile.errors[:city].size).to eq(1)
    expect(profile.errors[:zipcode].size).to eq(1)
  end

  it 'returns a contact full name as a string' do
    expect(build(:user_profile, first_name: 'Joe', last_name: 'Sandoval').full_name).to eq 'Joe Sandoval'
  end

  it 'returns the display name' do
    expect(build(:user_profile, public_name: 'joe').display_name).to eq 'joe'
  end

  it 'recognizes a filled in address and not filled in address' do
    profile = build(:user_profile, email: nil, first_name: nil, last_name: nil,
                                   address: nil, city: nil, zipcode: nil, country: nil)

    expect(profile.address_valid?).to be false

    profile = build(:user_profile, address: '14 S. Somewhere', city: 'SandCity', zipcode: '90201', country: build(:country))

    expect(profile.address_valid?).to be true
  end
end
