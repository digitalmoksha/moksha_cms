require 'spec_helper'

describe DmCore::Language do
  context '#translate_url' do
    it 'already has a language specifier' do
      expect(described_class.translate_url('http://example.com/en/test', :de)).to eq 'http://example.com/de/test'
    end

    it 'is only a root path' do
      expect(described_class.translate_url('http://example.com', :de)).to eq 'http://example.com/de/'
    end

    it 'has a dangling language specifier' do
      expect(described_class.translate_url('http://example.com/en', :de)).to eq 'http://example.com/de/'
    end

    it 'does not have a language specifier' do
      expect(described_class.translate_url('http://example.com/test', :de)).to eq 'http://example.com/de/test'
    end
  end
end
