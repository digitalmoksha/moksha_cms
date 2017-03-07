# In general, the default_url_options method of our controller never
# gets called, so the default locale parameter for our url's is never
# set.
#
# There are two issues with the locale value on urls:
# 1. for routes in the code (redirects, url_for, etc), we need the monkey 
#    patch for ActionView and ActionDispatch
#    Ref: https://github.com/rspec/rspec-rails/issues/255#issuecomment-24796864
#
# 2. for the 'get', 'post', etc, methods in our specs, use the DefaultParams
#    below, which will set the locale for the get/post automatically, so we don't
#    have to specify it on each invocation
#    Ref: https://gist.github.com/PikachuEXE/8110084
#
# Ref: https://github.com/rspec/rspec-rails/issues/255
#------------------------------------------------------------------------------

# 1.
#------------------------------------------------------------------------------
class ActionView::TestCase::TestController
  def default_url_options(options={})
    { locale: I18n.default_locale }
  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  def call(t, args)
    t.url_for(handle_positional_args(t, args, { locale: I18n.default_locale }.merge( @options ), @segment_keys))
  end
end

# 2.
#------------------------------------------------------------------------------
require 'active_support/concern'
 
module DefaultParams
  extend ActiveSupport::Concern
 
  included do
    let(:default_params) { {locale: I18n.locale} }
 
    def process_with_default_params(action, http_method = 'GET', *args)
      parameters = args.shift
 
      parameters = default_params.merge(parameters || {})
      args.unshift(parameters)
 
      process_without_default_params(action, http_method, *args)
    end
 
    alias_method_chain :process, :default_params
  end
end
 
RSpec.configure do |config|
  config.include(DefaultParams, :type => :controller)
end