require 'kramdown'

#------------------------------------------------------------------------------
module DmCore::LiquidHelper

  # Pass :view in a register so this view (with helpers) can be used inside of a tag
  #------------------------------------------------------------------------------
  def liquidize_textile(content, arguments = {})
    doc = RedCloth.new(Liquid::Template.parse(content).render(arguments, :filters => [LiquidFilters], 
                              :registers => { :controller => controller, :view => self,
                                              :account_site_assets => account_site_assets,
                                              :current_user => current_user}))
    #doc.hard_breaks = false
    return doc.to_html.html_safe
  end

  # use the kramdown library
  #------------------------------------------------------------------------------
  def liquidize_markdown(content, arguments = {})
    doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, :filters => [LiquidFilters], 
                              :registers => { :controller => controller, :view => self, 
                                              :account_site_assets => account_site_assets,
                                              :current_user => current_user}),
                          :parse_block_html => true)
    return doc.to_html.html_safe
  end

  #------------------------------------------------------------------------------
  def liquidize_html(content, arguments = {})
    doc = Liquid::Template.parse(content).render(arguments, :filters => [LiquidFilters], 
                              :registers => { :controller => controller, :view => self, 
                                              :account_site_assets => account_site_assets,
                                              :current_user => current_user})
    return doc.html_safe
  end

  #------------------------------------------------------------------------------
  def markdown(content, options = {:safe => true})
    if options[:safe]
      BlueCloth.new(content, :remove_links => true, :remove_images => true, :escape_html => true).to_html.html_safe
    else
      ::Kramdown::Document.new(content).to_html.html_safe
    end
  end

end