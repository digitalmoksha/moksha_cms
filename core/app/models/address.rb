class Address < ApplicationRecord
  self.table_name = 'core_addresses'
  belongs_to        :addressable, :polymorphic => true

  attr_accessor     :name

  biggs :postal_address,
          :recipient => :name,
          :country => :country_code,
          :street => Proc.new {|address| "#{address.line1} #{address.line2}" }

  #------------------------------------------------------------------------------
  def to_s(name_to_use = '')
    self.name = name_to_use
    postal_address.strip
  end

  #------------------------------------------------------------------------------
  def to_html(name_to_use = '')
    # self.to_s(name_to_use).gsub("\n", "<br/>".html_safe)
    self.to_s(name_to_use).split(/\n/).xss_aware_join('<br>'.html_safe)
  end
end
