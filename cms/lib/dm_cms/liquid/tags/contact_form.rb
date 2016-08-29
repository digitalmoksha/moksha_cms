#------------------------------------------------------------------------------
module Liquid
  class ContactForm < DmCore::LiquidTag
    
    #------------------------------------------------------------------------------
    def render(context)
      partial_name = @attributes['name'].present? ? "#{@attributes['name']}_contact_form" : 'contact_form'
      context.registers[:view].render(:partial => "liquid_tags/#{partial_name}")
    end

    #------------------------------------------------------------------------------
    def self.details
      { name: self.tag_name,
        summary: 'Contact form tag',
        category: 'form',
        description: <<-END_OF_DESCRIPTION
Includes a system standard contact form.

~~~
{% contact_form %}
~~~

If you have a custom form, provide it's name

~~~
{% contact_form name: tech_support %}
~~~

END_OF_DESCRIPTION
      }
    end
  end
  Template.register_tag('contact_form', ContactForm)
end

