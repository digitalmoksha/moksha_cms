class MailchimpNewsletterSubscriber < NewsletterSubscriber
  attr_accessor :member_info_data, :email, :euid, :subscribed, :grouping_id, :groups

  # is subscriber interested in the named group?
  #------------------------------------------------------------------------------
  def interest_group?(name)
    group = groups.detect { |group| group['name'] == name } if groups
    (group ? group['interested'] : false)
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
    obj.subscribed        = attributes['status'] == 'subscribed' ? true : false
    obj.email             = attributes['email']
    obj.euid              = attributes['euid']
    obj.grouping_id       = attributes['merges']['GROUPINGS'] ? attributes['merges']['GROUPINGS'][0]['id'] : nil
    obj.groups            = attributes['merges']['GROUPINGS'] ? attributes['merges']['GROUPINGS'][0]['groups'] : nil
    obj
  end

  # Query for the subscriber info.
  #------------------------------------------------------------------------------
  def self.subscriber_info(newsletter, email)
    api         = MailchimpNewsletter.api
    subscriber  = api.lists.member_info(id: newsletter.mc_id, emails: [email: email])
    if subscriber['success_count'] == 1
      return MailchimpNewsletterSubscriber.new_from_mailchimp(subscriber['data'][0])
    else
      return nil
    end
  end
end
