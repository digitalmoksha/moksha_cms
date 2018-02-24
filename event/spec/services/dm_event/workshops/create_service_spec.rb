require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe DmEvent::Workshops::CreateService, type: :service do
  setup_account

  describe '#call' do
    it 'creates a new workshop' do
      workshop = create_workshop(attributes_for(:workshop))

      expect(workshop).to be_persisted
    end
  end

  #------------------------------------------------------------------------------
  def create_workshop(opts)
    DmEvent::Workshops::CreateService.new(opts).call
  end
end
