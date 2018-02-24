require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe DmEvent::Workshops::DestroyService, type: :service do
  setup_account

  let!(:workshop)   { create(:workshop) }

  subject(:service) { described_class.new(workshop) }

  describe '#call' do
    it 'destroys a workshop' do
      expect { service.call }.to change(Workshop, :count).by(-1)
    end
  end
end
