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
        binding.pry
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
