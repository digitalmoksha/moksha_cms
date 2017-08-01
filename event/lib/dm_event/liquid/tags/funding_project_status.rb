module Liquid
  # {% video_frame width : 720, caption : 'some caption', class : some_class
  #          title: 'some_title', :id : some_id, alt : alt_text, side : right %}
  #------------------------------------------------------------------------------
  class FundingProjectStatus < DmCore::LiquidBlock
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    # include Sprockets::Rails::Helper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'class' => '', 'width' => '', 'style' => '', 
                                  'button_text' => '', 'button_link' => ''

      output                = super
      content               = output.strip
      workshop_id           = @attributes['project_id'] unless @attributes['project_id'].blank?
      image                 = file_url(@attributes["image"], base: "#{context_account_site_assets(context)}/images", protected: @attributes['protected'].as_boolean)
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