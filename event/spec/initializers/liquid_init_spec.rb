# frozen_string_literal: true

require 'spec_helper'

describe 'Liquid tag loader', type: :liquid_tag do
  setup_account

  Dir.glob(File.expand_path('../../../app/liquid/tags/*.rb', __FILE__)).sort.each do |path|
    tag_name = File.basename(path, ".*")

    it "loads tag `#{tag_name}`" do
      expect(Liquid::Template.tags[tag_name]).not_to eq nil
    end
  end
end
