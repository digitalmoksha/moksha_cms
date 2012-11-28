module DmCore
  module UrlHelper

    # Takes the full url path and converts to another locale
    #------------------------------------------------------------------------------
    def url_translate(locale)
      DmCore::Language.translate_url(request.url, locale)
    end
    
    # Usually don't care if a form submits a PUT or POST.  Was something submitted?
    #------------------------------------------------------------------------------
    def put_or_post?
      request.put? || request.post?
    end
  
  end
end
