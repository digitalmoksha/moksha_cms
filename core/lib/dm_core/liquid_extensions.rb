# Allow Liquid tags to be namespaced, based on the account_prefix.  This allows
# multiple sites to have tags named the same, but the correct one will get used
# during rendering 
#------------------------------------------------------------------------------
module Liquid
  class Template
    class << self
      
      #------------------------------------------------------------------------------
      def register_tag(name, klass)
        register_tag_namespace(name, klass)
      end
      
      #------------------------------------------------------------------------------
      def register_tag_namespace(name, klass, namespace = 'top')
        tags_namespaced(namespace)[name.to_s] = klass
      end
      
      #------------------------------------------------------------------------------
      def tags
        if Account.current.nil?
          tags_namespaced('top')
        else
          tags_namespaced('top').merge(tags_namespaced(Account.current.account_prefix))
        end
      end
      
      #------------------------------------------------------------------------------
      def tags_namespaced(namespace)
        @tags_namespaced            ||= {}
        @tags_namespaced[namespace] ||= {}
      end
    end
  end
end

#------------------------------------------------------------------------------
module LiquidExtensions
  module Helpers
    # So that tags can render Erb and have access to normal Rails helpers
    # http://robots.thoughtbot.com/post/159806314/custom-tags-in-liquid
    #------------------------------------------------------------------------------
    def render_erb(context, file_name, locals = {})
      context.registers[:controller].send(:render_to_string, :partial => file_name, :locals => locals)
    end
  end
end

# Pull common setup functions of Tag and Block
#------------------------------------------------------------------------------
module DmCore
  class LiquidTag < Liquid::Tag
    include LiquidExtensions::Helpers

    SimpleSyntax = /#{Liquid::QuotedFragment}/        
    NamedSyntax = /(#{Liquid::QuotedFragment})\s*\:\s*(#{Liquid::QuotedFragment})/

    #------------------------------------------------------------------------------
    def initialize(tag_name, markup, tokens)      
      @attributes    = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = ((value.delete "\"").delete "\'")
      end
      super
    end
  end
end

module DmCore
  class LiquidBlock < Liquid::Block
    include LiquidExtensions::Helpers

    SimpleSyntax = /#{Liquid::QuotedFragment}/        
    NamedSyntax = /(#{Liquid::QuotedFragment})\s*\:\s*(#{Liquid::QuotedFragment})/

    #------------------------------------------------------------------------------
    def initialize(tag_name, markup, tokens)      
      @attributes    = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = ((value.delete "\"").delete "\'")
      end
      super    
    end
  end
end