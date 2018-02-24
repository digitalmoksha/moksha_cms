require 'spec_helper'

describe User do
  setup_account

  #------------------------------------------------------------------------------
  it "creates a new instance given a valid attribute" do
    user = create(:user)

    expect(user.class).to eq described_class
    expect(FactoryBot.build(:user)).to be_valid
  end

  #------------------------------------------------------------------------------
  it "requires an email address" do
    no_email_user = build(:user, email: "")

    expect(no_email_user).not_to be_valid
  end

  #------------------------------------------------------------------------------
  it "accepts valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      expect(build(:user, email: address)).to be_valid
    end
  end

  #------------------------------------------------------------------------------
  it "rejects invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      expect(build(:user, email: address)).not_to be_valid
    end
  end

  #------------------------------------------------------------------------------
  it "rejects duplicate email addresses" do
    create(:user, email: 'dup@test.com')

    expect(build(:user, email: 'dup@test.com')).not_to be_valid
  end

  #------------------------------------------------------------------------------
  it "rejects email addresses identical up to case" do
    create(:user, email: 'dup@test.com'.upcase)

    expect(build(:user, email: 'dup@test.com'.upcase)).not_to be_valid
  end

  describe "passwords" do
    before do
      @user = build(:user)
    end

    #------------------------------------------------------------------------------
    it "has a password attribute" do
      expect(@user).to respond_to(:password)
    end

    #------------------------------------------------------------------------------
    it "has a password confirmation attribute" do
      expect(@user).to respond_to(:password_confirmation)
    end
  end

  describe "password validations" do
    #------------------------------------------------------------------------------
    it "requires a password" do
      expect(build(:user, password: '', password_confirmation: '')).not_to be_valid
    end

    #------------------------------------------------------------------------------
    it "requires a matching password confirmation" do
      expect(build(:user, password: '123456789', password_confirmation: 'x123456789y')).not_to be_valid
    end

    #------------------------------------------------------------------------------
    it "rejects short passwords" do
      short = "a" * 7

      expect(build(:user, password: short, password_confirmation: short)).not_to be_valid
    end
  end

  describe "password encryption" do
    before do
      @user = create(:user)
    end

    #------------------------------------------------------------------------------
    it "has an encrypted password attribute" do
      expect(@user).to respond_to(:encrypted_password)
    end

    #------------------------------------------------------------------------------
    it "sets the encrypted password attribute" do
      expect(@user.encrypted_password).not_to be_blank
    end
  end
end
