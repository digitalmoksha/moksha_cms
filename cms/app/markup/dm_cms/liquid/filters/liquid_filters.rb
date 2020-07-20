module DmCms
  module Liquid
    module Filters
      module LiquidFilters
        include ActionView::Helpers::NumberHelper

        #------------------------------------------------------------------------------
        def currency(price)
          number_to_currency(price)
        end
      end
    end
  end

  ::Liquid::Template.register_filter(Liquid::Filters::LiquidFilters)
end
