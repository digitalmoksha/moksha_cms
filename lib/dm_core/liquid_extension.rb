# Allow Liquid tags to be namespaced, based on the account_prefix.  This allows
# multiple sites to have tags named the same, but the correct one will get used
# during rendering 
#------------------------------------------------------------------------------
require 'liquid'

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
