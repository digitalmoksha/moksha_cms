# Based on the Railscast: http://railscasts.com/episodes/287-presenters-from-scratch
#------------------------------------------------------------------------------
class BasePresenter
  include DmCore::LiquidHelper

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
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end