require 'spec_helper'

describe Account do
  setup_account
  
  it "write tests"
  
  it "has default url values" do
    expect(Account.current.url_protocol).to eq 'http://'
    expect(Account.current.url_host).to eq 'test.example.com'
    expect(Account.current.url_base).to eq 'http://test.example.com'
  end
  
  it "sets the set_url_parts" do
    Account.current.set_url_parts('https://', 'test.sample.com:3000')
    expect(Account.current.url_protocol).to eq 'https://'
    expect(Account.current.url_host).to eq 'test.sample.com:3000'
    expect(Account.current.url_base).to eq 'https://test.sample.com:3000'
  end
end