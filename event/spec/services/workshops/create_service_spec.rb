require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe DmEvent::Workshops::CreateService, type: :service do
  setup_account

  describe '#call' do
    it 'creates a new workshop' do
      workshop = create_workshop(attributes_for(:workshop))
      expect(workshop.persisted?).to be_truthy
    end
  end

  #------------------------------------------------------------------------------
  def create_workshop(opts)
    DmEvent::Workshops::CreateService.new(opts).call
  end
end
