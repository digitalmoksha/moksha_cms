require 'spec_helper'
require_relative Rails.root.join '../../../core/spec/concerns/public_private_shared'

describe Forum do
  setup_account

  it_behaves_like :public_private_protected, :forum

  #------------------------------------------------------------------------------
  it 'write tests'
end