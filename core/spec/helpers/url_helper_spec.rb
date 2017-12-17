require 'spec_helper'

# include DmCore::AccountHelper

describe DmCore::UrlHelper do
  it 'translates the url to a different local' do
    helper.request.path = '/en/test'
    expect(helper.send(:url_translate, :de)).to eq 'http://test.host/de/test'
  end
end