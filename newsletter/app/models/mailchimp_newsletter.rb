# Integrates MailChimp into our system.  Using the 'gibbon' gem to interface
# with MailChimp API V2
#------------------------------------------------------------------------------
class MailchimpNewsletter < Newsletter

  MAILCHIMP_ERRORS = {  200 => 'List_DoesNotExist',
                        214 => 'List_AlreadySubscribed',
                        232 => 'Email_NotExists'
                     }.freeze

  validate        :validate_list_id
  after_create    :update_list_stats
  
  #------------------------------------------------------------------------------
  def self.signup_information(token, options = {})
    information = { newsletter: self.find_newsletter(token, options) }
    if information[:newsletter]
      information[:grouping] = information[:newsletter].groupings[0]
      if options[:current_user]
        subscriber = MailchimpNewsletterSubscriber.subscriber_info(information[:newsletter], options[:current_user].email)
        information[:subscriber] = (subscriber && subscriber.subscribed? ? subscriber : nil)
      end
    end
    return information
  end

  # Make sure list id is specified, and it's valid with MailChimp
  #------------------------------------------------------------------------------
  def validate_list_id
    unless self.mc_id.blank?
      api         = MailchimpNewsletter.api
      list_info   = api.lists.list(filters: {list_id: self.mc_id, exact: true})
      if !list_info['errors'].empty?
        errors[:mc_id] << (list_info['errors'][0]['error'])
      end
    else  
      errors[:mc_id] << ("list id must be provided")
    end
  end 

  # Retrieve list of groupings from Mailchimp
  #------------------------------------------------------------------------------
  def groupings
    api       = MailchimpNewsletter.api
    groupings = api.lists.interest_groupings(id: self.mc_id)
  end
  
  # subscribe user or email to the newsletter
  #------------------------------------------------------------------------------
  def subscribe(user_or_email, options = {FNAME: '', LNAME: ''})
    return { success: false, code: 232 } if user_or_email.blank?
    api        = MailchimpNewsletter.api
    
    #--- remove any invalid merge vars or other options
    merge_vars = options.except('new-email', :email, :optin_ip, :optin_time, :mc_location,
                                :mc_language, :mc_notes, :update_existing)

    #--- groupings needs to be an Array, but the form usually sends it as a Hash
    merge_vars['GROUPINGS'] = [merge_vars['GROUPINGS']] if merge_vars['GROUPINGS'] && !merge_vars['GROUPINGS'].is_a?(Array)

    #--- update data if user logged in. Don't for an unprotected subscribe. but honor value if passed in
    options.reverse_merge!  update_existing: user_or_email.is_a?(User)

    if user_or_email.is_a?(User)
      email               = {email: user_or_email.email}
      merge_vars[:FNAME]  = user_or_email.first_name
      merge_vars[:LNAME]  = user_or_email.last_name
    else
      email               = {email: user_or_email}
    end
    merge_vars[:SPAMAPI]  = 1
    api.lists.subscribe(id: self.mc_id, email: email, merge_vars: merge_vars, 
                        double_optin: true, update_existing: options[:update_existing], replace_interests: true)
    return { success: true, code: 0, update_existing: options[:update_existing] }
  rescue Gibbon::MailChimpError => exception
    Rails.logger.info "=== Error Subscribing #{email} : #{exception.to_s}"
    return { success: false, code: exception.code, update_existing: options[:update_existing] }
  end

  # unsubscribe email from the newsletter
  #------------------------------------------------------------------------------
  def unsubscribe(email)
    return false if email.blank?

    api = MailchimpNewsletter.api
    api.lists.unsubscribe(id: self.mc_id, email: {email: email}, delete_member: false, send_goodbye: true, send_notify: true)
    return true
  rescue Gibbon::MailChimpError => exception
    Rails.logger.info "=== Error Unsubscribing #{email} : #{exception.to_s}"
    return false
  end

  #------------------------------------------------------------------------------
  def update_list_stats
    api         = MailchimpNewsletter.api
    list_info   = api.lists.list(filters: {list_id: self.mc_id, exact: true})

    #--- update the newsletter
    if list_info['errors'].empty?
      self.update_attributes(
        name:               list_info['data'][0]['name'],
        subscribed_count:   list_info['data'][0]['stats']['member_count'],
        unsubscribed_count: list_info['data'][0]['stats']['unsubscribe_count'],
        cleaned_count:      list_info['data'][0]['stats']['cleaned_count'],
        created_at:         list_info['data'][0]['date_created'])
    else
      #--- looks like the list was deleted at MailChimp, mark as deleted
      self.update_attribute(:deleted, true)
    end
  end

  #------------------------------------------------------------------------------
  def map_error_to_msg(code)
    return MAILCHIMP_ERRORS[code] ? "nms.#{MAILCHIMP_ERRORS[code]}" : 'nms.mc_unknown_error'
  end
  
  # Grab an API object to work with
  #------------------------------------------------------------------------------
  def self.api
    if !Account.current.preferred_nms_api_key.blank?
      Gibbon::API.new(Account.current.preferred_nms_api_key)
    else
      nil
    end
  end
  
  # Query the lists in MailChimp, and create / update what we have in the database.
  # If a list no longer exists, we will delete it and any attached information
  # Note: [todo] This function is currently not used.  Still determining if it's needed.
  #       Keep here until final decision.
  #------------------------------------------------------------------------------
  # def self.synchronize
  #   newsletters = MailchimpNewsletter.find(:all)
  #   api         = MailchimpNewsletter.api
  #   lists       = api.lists.list
  #   
  #   unless lists['data'].nil?
  #     lists['data'].each do |list|
  #       index = newsletters.find_index { |item| item.mc_id == list['id'] }
  #       if index
  #         #--- update the newsletter
  #         newsletters[index].update_attributes(
  #           name:               list['name'],
  #           subscribed_count:   list['stats']['member_count'],
  #           unsubscribed_count: list['stats']['unsubscribe_count'],
  #           cleaned_count:      list['stats']['cleaned_count'])
  #         newsletters.delete_at(index)
  #       else
  #         #--- create a new newsletter
  #         MailchimpNewsletter.create!(
  #           name:               list['name'], 
  #           mc_id:              list['id'],
  #           created_at:         list['date_created'])
  #       end
  #     end
  # 
  #     #--- if any left, then mark them as deleted
  #     newsletters.each { |old_list| old_list.update_attribute(:deleted, true) }
  #     
  #     #--- update the lists_synced_on time
  #     account = Account.current
  #     account.preferred_nms_lists_synced_on = Time.now
  #     account.save
  #   end
  # rescue Gibbon::MailChimpError
  # end
  
end