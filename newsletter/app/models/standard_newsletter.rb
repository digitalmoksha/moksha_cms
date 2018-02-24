# This is the standard or "manual" newsletter class - all newsletter subscription
# funtions are handled internally.  This is in case you don't want to use the
# integration with MailChimp
#------------------------------------------------------------------------------
class StandardNewsletter < Newsletter
  validates_presence_of :name

  #------------------------------------------------------------------------------
  def self.signup_information(token, options = {})
    #--- [todo] implement
  end

  #------------------------------------------------------------------------------
  def map_error_to_msg(code)
    #--- [todo] implement
  end
end
