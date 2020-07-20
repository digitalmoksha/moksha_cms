module DmCms
  module Liquid
    module Tags
      class ContactForm < DmCore::LiquidTag
        #------------------------------------------------------------------------------
        def render(context)
          partial_name = @attributes['name'].present? ? "#{@attributes['name']}_contact_form" : 'contact_form'
          context.registers[:view].render(partial: "liquid_tags/#{partial_name}")
        end

        #------------------------------------------------------------------------------
        def self.details
          {
            name: tag_name,
            summary: 'Contact form tag',
            category: 'form',
            description: description
          }
        end

        #------------------------------------------------------------------------------
        def self.description
          <<-DESCRIPTION.strip_heredoc
          Includes a system standard contact form.
    
          ~~~
          {% contact_form %}
          ~~~
    
          If you have a custom form, provide it's name
    
          ~~~
          {% contact_form name: tech_support %}
          ~~~
          DESCRIPTION
        end
      end
    end
  end

  ::Liquid::Template.register_tag('contact_form', Liquid::Tags::ContactForm)
end
