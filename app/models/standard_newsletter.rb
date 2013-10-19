# This is the standard or "manual" newsletter class - all newsletter subscription
# funtions are handled internally.  This is in case you don't want to use the
# integration with MailChimp
#------------------------------------------------------------------------------
class StandardNewsletter < Newsletter

  validates_presence_of   :name

end