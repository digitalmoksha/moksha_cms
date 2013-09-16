module Liquid
  # {% video_frame width : 720, caption : 'some caption', class : some_class
  #          title: 'some_title', :id : some_id, alt : alt_text, side : right %}
  #------------------------------------------------------------------------------
  class FundingProjectStatus < DmCore::LiquidBlock
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'class' => '', 'width' => '', 'style' => '', 
                                  'button_text' => '', 'button_link' => ''

      output                = super
      content               = output.strip
      workshop_id           = @attributes['project_id'] unless @attributes['project_id'].blank?
      image                 = file_path(@attributes["image"], context)
      @attributes['style'] += css_style_width(@attributes['width'])
      
      context.registers[:view].render(partial: 'dm_event/liquid_tags/funding_project_status', 
                      locals: { content: content,
                                workshop_id: workshop_id,
                                image: image,
                                div_class: @attributes['class'],
                                div_style: @attributes['style'],
                                button_text: @attributes['button_text'],
                                button_link: @attributes['button_link']
                             })
    end

    #------------------------------------------------------------------------------
    def file_path(file_name, context)
      path = @attributes['protected'].as_boolean ? "/protected_asset/" : "#{context.registers[:account_site_assets]}/images/"
      expand_url(file_name, path)
    end

    def self.details
      { name: self.tag_name,
        summary: 'Funding Project Status',
        description: "",
        example: self.example,
        category: 'structure'
      }
    end
    def self.example
      example = <<-END_OF_STRING
{% funding_project_status  %}
...content
{% endfunding_project_status %}
END_OF_STRING
    end
  end

  Template.register_tag('funding_project_status', FundingProjectStatus)
  
end