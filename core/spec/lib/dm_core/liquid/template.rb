# frozen_string_literal: true

require 'spec_helper'

describe Liquid::Template, type: :liquid_tag do
  class TestTag1; end
  class TestTag2; end
  class TestTag3; end

  describe '#tags' do
    before do
      ::Liquid::Template.register_tag_namespace('tag_1', TestTag1, 'test')
      ::Liquid::Template.register_tag_namespace('tag_2', TestTag2, 'another_theme')
      ::Liquid::Template.register_tag_namespace('tag_1', TestTag3, 'another_theme')
    end

    context 'when Account.current is nil' do
      it 'includes default Liquid tags' do
        expect(described_class.tags['tablerow']).to eq Liquid::TableRow
        expect(described_class.tags['case']).to eq Liquid::Case
      end

      it 'does not include theme tags' do
        expect(described_class.tags['tag_1']).to be_nil
        expect(described_class.tags['tag_2']).to be_nil
      end
    end

    context 'when there is an Account' do
      setup_account

      it 'includes default Liquid tags' do
        expect(described_class.tags['tablerow']).to eq Liquid::TableRow
        expect(described_class.tags['case']).to eq Liquid::Case
      end

      it 'includes the theme tag' do
        expect(described_class.tags['tag_1']).to eq TestTag1
        expect(described_class.tags['tag_2']).to be_nil
      end

      it 'does not include other theme tags' do
        account = FactoryBot.create(:account, account_prefix: 'another_theme')
        Account.current_by_prefix(account.account_prefix)

        expect(described_class.tags['tag_1']).to eq TestTag3
        expect(described_class.tags['tag_2']).to eq TestTag2

        Account.current_by_prefix('test')

        expect(described_class.tags['tag_1']).to eq TestTag1
        expect(described_class.tags['tag_2']).to be_nil
      end
    end
  end
end
