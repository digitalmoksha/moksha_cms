class MailchimpNewsletterSubscriber < NewsletterSubscriber
  attr_accessor :member_info_data, :email, :euid, :subscribed, :grouping_id, :groups

  # is subscriber interested in the named group?
  #------------------------------------------------------------------------------
  def interest_group?(id)
    return false unless groups

    groups[id.to_sym] || false
  end

  #------------------------------------------------------------------------------
  def subscribed?
    subscribed
  end

  # Instantiate a new subscriber based on data from a Mailchimp query like
  # member_info.  Does nothing with the database at this time.
  #------------------------------------------------------------------------------
  def self.new_from_mailchimp(attributes = {})
    obj = MailchimpNewsletterSubscriber.new
    obj.member_info_data  = attributes
    obj.subscribed        = attributes[:status] == 'subscribed'
    obj.email             = attributes[:email_address]
    obj.euid              = attributes[:unique_email_id]
    obj.groups            = attributes[:interests] || nil

    obj
  end

  # Query for the subscriber info.
  #------------------------------------------------------------------------------
  def self.subscriber_info(newsletter, email)
    subscriber = newsletter.subscriber_info(email)

    subscriber ? MailchimpNewsletterSubscriber.new_from_mailchimp(subscriber) : nil
  end
end
