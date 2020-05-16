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

      # Store tags in a namespace, usually a theme name.  This is so we can register
      # many different tags for each theme and keep them separate.
      #------------------------------------------------------------------------------
      def register_tag_namespace(name, klass, namespace = 'system_tags')
        tags_namespaced(namespace)[name.to_s] = klass
      end

      # return the list of tags that are available.  Tags available at any instance is
      # the global tags, the current theme's tags, and the parent theme's tags.
      # theme tags will override global tags
      #------------------------------------------------------------------------------
      def tags
        @theme_tags ||= {}
        return @tags if Account.current.nil?
        return @theme_tags[Account.current.current_theme] if @theme_tags[Account.current.current_theme]

        @theme_tags[Account.current.current_theme] = @tags.dup

        add_namespaced_tags(@theme_tags[Account.current.current_theme], 'system_tags')

        unless Account.current.nil?
          add_namespaced_tags(@theme_tags[Account.current.current_theme], Account.current.parent_theme) if Account.current.parent_theme
          add_namespaced_tags(@theme_tags[Account.current.current_theme], Account.current.current_theme)
        end

        @theme_tags[Account.current.current_theme]
      end

      #------------------------------------------------------------------------------
      def tags_namespaced(namespace)
        @tags_namespaced            ||= {}
        @tags_namespaced[namespace] ||= {}
      end

      #------------------------------------------------------------------------------
      def add_namespaced_tags(tag_registry, namespace)
        tags_namespaced(namespace).each_pair { |tag_name, klass| tag_registry[tag_name] = klass }
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
      context.registers[:controller].send(:render_to_string, partial: file_name, locals: locals) # rubocop:disable GitlabSecurity/PublicSend
    end

    #------------------------------------------------------------------------------
    def context_account_site_assets(context)
      context.registers[:account_site_assets]
    end

    #------------------------------------------------------------------------------
    def context_account_site_assets_media(context)
      context.registers[:account_site_assets_media]
    end
  end
end

# Pull common setup functions of Tag and Block
#------------------------------------------------------------------------------
module DmCore
  class LiquidTag < Liquid::Tag
    include LiquidExtensions::Helpers

    SimpleSyntax = /#{Liquid::QuotedFragment}/.freeze # rubocop:disable Naming/ConstantName
    NamedSyntax = /(#{Liquid::QuotedFragment})\s*\:\s*(#{Liquid::QuotedFragment})/.freeze # rubocop:disable Naming/ConstantName

    #------------------------------------------------------------------------------
    def initialize(tag_name, markup, tokens)
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = ((value.delete "\"").delete "\'")
      end
      super
    end

    class << self
      #------------------------------------------------------------------------------
      def tag_name
        name.split('::').last.underscore
      end

      def details
        { name: tag_name, summary: '', description: '', example: '', category: '' }
      end
    end
  end
end

module DmCore
  class LiquidBlock < Liquid::Block
    include LiquidExtensions::Helpers

    SimpleSyntax = /#{Liquid::QuotedFragment}/.freeze # rubocop:disable Naming/ConstantName
    NamedSyntax = /(#{Liquid::QuotedFragment})\s*\:\s*(#{Liquid::QuotedFragment})/.freeze # rubocop:disable Naming/ConstantName

    #------------------------------------------------------------------------------
    def initialize(tag_name, markup, tokens)
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = ((value.delete "\"").delete "\'")
      end
      super
    end

    # Liquid will automatically throw away a block with empty/blank content.
    # Call this in the tag's render method to allow the tag to be rendered anyway
    #------------------------------------------------------------------------------
    def allow_empty_block
      @blank = false
    end

    class << self
      #------------------------------------------------------------------------------
      def tag_name
        name.split('::').last.underscore
      end

      def details
        { name: tag_name, summary: '', description: '', example: '', category: '' }
      end
    end
  end
end
