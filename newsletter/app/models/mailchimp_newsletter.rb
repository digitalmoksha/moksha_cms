# Integrates MailChimp into our system.  Using the 'gibbon' gem to interface
# with MailChimp API V2
#------------------------------------------------------------------------------
class MailchimpNewsletter < Newsletter
  MAILCHIMP_ERRORS = {  200 => 'List_DoesNotExist',
                        212 => 'Email_WasRemoved',
                        214 => 'List_AlreadySubscribed',
                        232 => 'Email_NotExists',
                        234 => 'Email_TooManySignups' }.freeze

  validate        :validate_list_id
  after_create    :update_list_stats

  #------------------------------------------------------------------------------
  def self.signup_information(token, options = {})
    information = { newsletter: find_newsletter(token, options) }
    if information[:newsletter]
      information[:grouping] = information[:newsletter].groupings[0]
      if options[:current_user]
        subscriber = MailchimpNewsletterSubscriber.subscriber_info(information[:newsletter], options[:current_user].email)
        information[:subscriber] = (subscriber&.subscribed? ? subscriber : nil)
      end
    end
    information
  end

  # Make sure list id is specified, and it's valid with MailChimp
  #------------------------------------------------------------------------------
  def validate_list_id
    if mc_id.blank?
      errors[:mc_id] << ("list id must be provided")
    else
      api         = MailchimpNewsletter.api
      list_info   = api.lists.list(filters: { list_id: mc_id, exact: true })
      if !list_info['errors'].empty?
        errors[:mc_id] << (list_info['errors'][0]['error'])
      end
    end
  end

  # Retrieve list of groupings from Mailchimp
  #------------------------------------------------------------------------------
  def groupings
    begin
      api = MailchimpNewsletter.api
      api.lists.interest_groupings(id: mc_id)
    rescue Gibbon::MailChimpError
      # groupings are not enabled for this list
      return []
    end
  end

  # subscribe user or email to the newsletter
  # Setting the Accept-Language will cause MC to send the confirmation in the users
  # language if the list auto-translate is turned on
  #------------------------------------------------------------------------------
  def subscribe(user_or_email, options = { FNAME: '', LNAME: '' })
    return { success: false, code: 232 } if user_or_email.blank?

    api         = MailchimpNewsletter.api
    headers     = { 'Accept-Language' => I18n.locale.to_s }

    # update data if user logged in. Don't for an unprotected subscribe. but honor value if passed in
    options.reverse_merge! update_existing: user_or_email.is_a?(User)

    # remove any invalid merge vars or other options
    merge_vars = options.except('new-email', :email, :optin_ip, :optin_time, :mc_location, :mc_notes,
                                :update_existing, :mc_language, :headers)

    # groupings needs to be an Array, but the form usually sends it as a Hash
    merge_vars['GROUPINGS'] = [merge_vars['GROUPINGS']] if merge_vars['GROUPINGS'] && !merge_vars['GROUPINGS'].is_a?(Array)

    if user_or_email.is_a?(User)
      email                 = { email: user_or_email.email }
      merge_vars[:FNAME]    = user_or_email.first_name
      merge_vars[:LNAME]    = user_or_email.last_name
      merge_vars[:COUNTRY]  = user_or_email.country.english_name if user_or_email.country
    else
      email = { email: user_or_email }
    end
    merge_vars[:SPAMAPI]      = 1
    merge_vars[:MC_LANGUAGE]  = I18n.locale # set the language to the current locale they are using
    api.lists.subscribe(id: mc_id, email: email, merge_vars: merge_vars,
                        double_optin: true, update_existing: options[:update_existing], replace_interests: true,
                        headers: headers)
    return { success: true, code: 0 }
  rescue Gibbon::MailChimpError => exception
    Rails.logger.info "=== Error Subscribing #{email} : code: #{exception.code} msg: #{exception}"
    return { success: false, code: exception.code }
  end

  # unsubscribe email from the newsletter
  #------------------------------------------------------------------------------
  def unsubscribe(email)
    return false if email.blank?

    api = MailchimpNewsletter.api
    api.lists.unsubscribe(id: mc_id, email: { email: email }, delete_member: false, send_goodbye: true, send_notify: true)
    return true
  rescue Gibbon::MailChimpError => exception
    Rails.logger.info "=== Error Unsubscribing #{email} : #{exception}"
    return false
  end

  #------------------------------------------------------------------------------
  def update_list_stats
    api         = MailchimpNewsletter.api
    list_info   = api.lists.list(filters: { list_id: mc_id, exact: true })

    # update the newsletter
    if list_info['errors'].empty?
      update_attributes(
        name:               list_info['data'][0]['name'],
        subscribed_count:   list_info['data'][0]['stats']['member_count'],
        unsubscribed_count: list_info['data'][0]['stats']['unsubscribe_count'],
        cleaned_count:      list_info['data'][0]['stats']['cleaned_count'],
        created_at:         list_info['data'][0]['date_created'])
    else
      # looks like the list was deleted at MailChimp, mark as deleted
      update_attribute(:deleted, true)
    end
  end

  # get a list of sent campaigns. Can specify :folder_id to get only those
  # in a specfic folder
  #------------------------------------------------------------------------------
  def sent_campaign_list(options = { start: 0, limit: 100 })
    api                 = MailchimpNewsletter.api
    list_params         = { sort_field: 'send_time', sort_dir: 'DESC',
                            filters: { list_id: mc_id } }
    list_params[:start] = options[:start] ? options[:start] : 0
    list_params[:limit] = options[:limit] ? options[:limit] : 100
    list_params[:filters][:folder_id] = options[:folder_id] if options[:folder_id]

    api.campaigns.list(list_params)
  end

  # Get simplified list of sent campaigns. Useful for showing archived
  # campaigns on the front end
  #------------------------------------------------------------------------------
  def sent_campaign_list_simple(options = { start: 0, limit: 100 })
    list = sent_campaign_list(options)
    list['data'].map do |item|
      { subject: item['subject'], sent_on: item['send_time'].to_datetime, archive_url: item['archive_url'] }
    end
  end

  #------------------------------------------------------------------------------
  def folder_list(type = 'campaign')
    api         = MailchimpNewsletter.api
    folder_list = api.folders.list(type: type)
    folder_list.sort! { |x, y| x['name'] <=> y['name'] }
  end

  #------------------------------------------------------------------------------
  def map_error_to_msg(code)
    MAILCHIMP_ERRORS[code] ? "nms.#{MAILCHIMP_ERRORS[code]}" : 'nms.mc_unknown_error'
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

  # is the email already subscribed to this list
  #------------------------------------------------------------------------------
  def email_subscribed?(email)
    subscriber = MailchimpNewsletterSubscriber.subscriber_info(self, email)
    subscriber.present? && subscriber.subscribed?
  end

  # Query the lists in MailChimp, and create / update what we have in the database.
  # If a list no longer exists, we will delete it and any attached information
  # Note: [todo] This function is currently not used.  Still determining if it's needed.
  #       Keep here until final decision.
  #------------------------------------------------------------------------------
  # def self.synchronize
  #   newsletters = MailchimpNewsletter.all
  #   api         = MailchimpNewsletter.api
  #   lists       = api.lists.list
  #
  #   unless lists['data'].nil?
  #     lists['data'].each do |list|
  #       index = newsletters.find_index { |item| item.mc_id == list['id'] }
  #       if index
  #         # update the newsletter
  #         newsletters[index].update_attributes(
  #           name:               list['name'],
  #           subscribed_count:   list['stats']['member_count'],
  #           unsubscribed_count: list['stats']['unsubscribe_count'],
  #           cleaned_count:      list['stats']['cleaned_count'])
  #         newsletters.delete_at(index)
  #       else
  #         # create a new newsletter
  #         MailchimpNewsletter.create!(
  #           name:               list['name'],
  #           mc_id:              list['id'],
  #           created_at:         list['date_created'])
  #       end
  #     end
  #
  #     # if any left, then mark them as deleted
  #     newsletters.each { |old_list| old_list.update_attribute(:deleted, true) }
  #
  #     # update the lists_synced_on time
  #     account = Account.current
  #     account.preferred_nms_lists_synced_on = Time.now
  #     account.save
  #   end
  # rescue Gibbon::MailChimpError
  # end
end
