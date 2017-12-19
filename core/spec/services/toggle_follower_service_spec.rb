require 'spec_helper'

# hijack this table/object so we can make followable
class SystemEmail < ApplicationRecord
  self.table_name       = 'core_system_emails'
  acts_as_followable
end

describe DmCore::ToggleFollowerService, type: :service do
  setup_account

  let(:user) { create :user }
  let(:item_to_follow) { SystemEmail.create }

  describe '#call' do
    let!(:service) { described_class.new(user, item_to_follow) }

    it 'toggles the following the object' do
      expect(user.following.follows?(item_to_follow)).to be_falsy
      expect(service.call).to be_truthy
      expect(user.following.follows?(item_to_follow)).to be_truthy
      expect(service.call).to be_falsy
      expect(user.following.follows?(item_to_follow)).to be_falsy
    end
  end
end
