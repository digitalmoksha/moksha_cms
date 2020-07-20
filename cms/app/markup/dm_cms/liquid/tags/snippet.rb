module DmCms
  module Liquid
    module Tags
      class Snippet < DmCore::LiquidTag
        include DmCore::AccountHelper
        include DmCore::LiquidHelper

        #------------------------------------------------------------------------------
        def render(context)
          output = ''
          if @attributes['slug'].present?
            cms_snippet = CmsSnippet.find_by_slug(@attributes['slug'])
            output = context.registers[:view].render_content_item(cms_snippet) if cms_snippet
          end
          output
        end

        #------------------------------------------------------------------------------
        def self.details
          {
            name: tag_name,
            summary: 'Display a snippet',
            category: 'structure',
            description: description
          }
        end

        #------------------------------------------------------------------------------
        def self.description
          <<-DESCRIPTION.strip_heredoc
          Output the content of a snippet specified by the slug
    
          ~~~
          {% snippet slug: 'some-snippet-slug'}
          ~~~
          DESCRIPTION
        end
      end
    end
  end

  ::Liquid::Template.register_tag('snippet', Liquid::Tags::Snippet)
end
