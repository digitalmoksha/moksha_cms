module DmNewsletter::NewslettersHelper
  #------------------------------------------------------------------------------
  def using_mailchimp?
    Account.current.preferred_nms_use_mailchimp?
  end
end