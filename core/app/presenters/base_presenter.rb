# Based on the Railscast: http://railscasts.com/episodes/287-presenters-from-scratch
#------------------------------------------------------------------------------
class BasePresenter

  #------------------------------------------------------------------------------
  def initialize(object, template)
    @object   = object
    @template = template
  end

private

  #------------------------------------------------------------------------------
  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  #------------------------------------------------------------------------------
  def h
    @template
  end

  #------------------------------------------------------------------------------
  def markdown(content, options = {:safe => true})
    if options[:safe]
      BlueCloth.new(content, :remove_links => true, :remove_images => true, :escape_html => true).to_html.html_safe
    else
      BlueCloth.new(content).to_html.html_safe
    end
  end
  
  #------------------------------------------------------------------------------
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end