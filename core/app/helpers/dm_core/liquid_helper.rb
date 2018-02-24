require 'kramdown'

# Note: do not make a call to current_user in this file.  Was not able to get
# that helper included in the mailers.
#------------------------------------------------------------------------------
module DmCore::LiquidHelper
  # Pass :view in a register so this view (with helpers) can be used inside of a tag
  # This assumes that the content is from a trusted source
  #------------------------------------------------------------------------------
  def liquidize_textile(content, arguments = {})
    doc = RedCloth.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters],
                                                                         registers: { controller: controller, view: self,
                                                                                      account_site_assets: account_site_assets_url,
                                                                                      account_site_assets_media: account_site_assets_media_url }))
    # doc.hard_breaks = false
    return doc.to_html.html_safe
  end

  # use the kramdown library
  # This assumes that the content is from a trusted source
  #------------------------------------------------------------------------------
  def liquidize_markdown(content, arguments = {})
    doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters],
                                                                                     registers: { controller: controller, view: self,
                                                                                                  account_site_assets: account_site_assets_url,
                                                                                                  account_site_assets_media: account_site_assets_media_url }),
                              parse_block_html: true)
    return doc.to_html.html_safe
  end

  # This assumes that the content is from a trusted source
  #------------------------------------------------------------------------------
  def liquidize_html(content, arguments = {})
    doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters],
                                                            registers: { controller: controller, view: self,
                                                                         account_site_assets: account_site_assets_url,
                                                                         account_site_assets_media: account_site_assets_media_url })
    return doc.html_safe
  end

  # Use Kramdown for parsing, then sanitize output.
  # Goal is to allow untrusted users to add comments/text with some formatting and
  # linking, but provide safe output
  #------------------------------------------------------------------------------
  def markdown(content = '', options = { safe: true }, &block)
    content ||= ''
    if block_given?
      html = ::Kramdown::Document.new(capture(&block)).to_html.html_safe
    else
      html = ::Kramdown::Document.new(content).to_html.html_safe
    end
    # for safety, use :basic or lower
    return options[:safe] ? sanitize_text(html, level: :basic).html_safe : html
  end

  # Uses Sanitize gem to fully sanitize any text.
  # Note: Default setting will make any markdown source (like user comments, etc)
  # safe for sending out in emails
  #------------------------------------------------------------------------------
  def sanitize_text(content, options = { level: :default })
    case options[:level]
    when :default
      # strip all html
      Sanitize.clean(content)
    when :restricted
      # Allows only very simple inline formatting markup. No links, images, or block elements.
      Sanitize.clean(content, Sanitize::Config::RESTRICTED)
    when :basic
      # Allows a variety of markup including formatting tags, links, and lists.
      # Images and tables are not allowed, links are limited to FTP, HTTP, HTTPS, and
      # mailto protocols, and a rel="nofollow" attribute is added to all links to
      # mitigate SEO spam.
      Sanitize.clean(content, Sanitize::Config::BASIC)
    when :relaxed
      # Allows an even wider variety of markup than BASIC, including images and tables.
      # Links are still limited to FTP, HTTP, HTTPS, and mailto protocols, while images
      # are limited to HTTP and HTTPS. In this mode, rel="nofollow" is not added to links.
      Sanitize.clean(content, Sanitize::Config::RELAXED)
    end
  end
end