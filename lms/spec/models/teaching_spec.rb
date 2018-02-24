require 'spec_helper'

describe Teaching do
  setup_account

  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }
  it { is_expected.to validate_length_of(:menutitle_en).is_at_most(255) }
end
