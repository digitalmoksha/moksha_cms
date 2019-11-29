# Integrates MailChimp into our system.  Using the 'gibbon' gem to interface
# with MailChimp API V2
#------------------------------------------------------------------------------
class MailchimpNewsletter < Newsletter
  MAILCHIMP_ERRORS = {  200 => 'List_DoesNotExist',
                        212 => 'Email_WasRemoved',
                        214 => 'List_AlreadySubscribed',
                        232 => 'Email_NotExists',
                        234 => 'Email_TooManySignups' }.freeze

  validate :validate_list_id

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
      errors[:mc_id] << "list id must be provided"
      return
    end

    begin
      api.lists(mc_id).retrieve(params: { fields: :id })
    rescue Gibbon::MailChimpError => e
      errors[:mc_id] << e.body[:title]
    end
  end

  # Retrieve list of groupings from Mailchimp
  #------------------------------------------------------------------------------
  def groupings
    return @interest_categories if @interest_categories

    response = api.lists(mc_id).interest_categories.retrieve
    @interest_categories = response.body[:categories] || []

    @interest_categories.each do |category|
      response = api.lists(mc_id).interest_categories(category[:id]).interests.retrieve
      category[:groups] = response.body[:interests]
    end

    @interest_categories
  rescue Gibbon::MailChimpError
    # groupings are not enabled for this list
    return []
  end

  #------------------------------------------------------------------------------
  def interest_ids(group)
    group.pluck(:id)
  end

  # subscribe user or email to the newsletter
  # Setting the Accept-Language will cause MC to send the confirmation in the users
  # language if the list auto-translate is turned on
  #------------------------------------------------------------------------------
  def subscribe(user_or_email, options = { FNAME: '', LNAME: '' }, new_subscription: false)
    return { success: false, code: 232 } if user_or_email.blank?

    # update data if user logged in. Don't for an unprotected subscribe. but honor value if passed in
    options[:update_existing] ||= user_or_email.is_a?(User) && !new_subscription

    headers    = { 'Accept-Language' => I18n.locale.to_s }
    email      = user_or_email.is_a?(User) ? user_or_email.email : user_or_email
    merge_vars = build_merge_vars(user_or_email, options)
    body       = build_body(email, merge_vars)

    return { success: false, code: 232 } if ValidatesEmailFormatOf.validate_email_format(email)

    unless options[:update_existing]
      if subscriber_info(email)
        # if it already exists, but we think it's new, then remove merge_vars.
        # we don't want someone changing the name on an email address from a
        # normal subscribe form.
        merge_vars = { SPAMAPI: 1 }
        body       = build_body(email, merge_vars)
      end

      body[:status] = 'pending' # make an opt-in email to be sent
    end

    md5_email_address = hash_email(email)
    api.lists(mc_id).members(md5_email_address).upsert(headers: headers, body: body)

    { success: true, code: 0 }
  rescue Gibbon::MailChimpError => e
    Rails.logger.info "=== Error Subscribing #{email} : code: #{e.status_code} msg: #{e.message}"

    { success: false, code: e.status_code }
  end

  # unsubscribe email from the newsletter
  #------------------------------------------------------------------------------
  def unsubscribe(email)
    return false if email.blank?
    return false if ValidatesEmailFormatOf.validate_email_format(email)

    api.lists(mc_id).members(hash_email(email)).update(body: { status: "unsubscribed" })

    true
  rescue Gibbon::MailChimpError => e
    Rails.logger.info "=== Error Unsubscribing #{email} : #{e.message}"

    false
  end

  #------------------------------------------------------------------------------
  def subscriber_info(email)
    results = api.lists(mc_id).members(hash_email(email)).retrieve

    results.body
  rescue Gibbon::MailChimpError => e
    Rails.logger.info "=== Error in subscriber_info for #{email} : #{e.message}" if e.status_code != 404

    nil
  end

  #------------------------------------------------------------------------------
  def update_list_stats
    list_info = api.lists(mc_id).retrieve

    # update the newsletter
    update_attributes(
      name:               list_info.body[:name],
      subscribed_count:   list_info.body[:stats][:member_count],
      unsubscribed_count: list_info.body[:stats][:unsubscribe_count],
      cleaned_count:      list_info.body[:stats][:cleaned_count],
      created_at:         list_info.body[:date_created])
  rescue Gibbon::MailChimpError
    # looks like the list was deleted at MailChimp, mark as deleted
    update_attribute(:deleted, true)
  end

  # get a list of sent campaigns. Can specify :folder_id to get only those
  # in a specfic folder
  #------------------------------------------------------------------------------
  def sent_campaign_list(options = { start: 0, limit: 100 })
    list_params             = { sort_field: 'send_time', sort_dir: 'DESC', list_id: mc_id }
    list_params[:offset]    = options[:start] ? options[:start] : 0
    list_params[:count]     = options[:limit] ? options[:limit] : 100
    list_params[:folder_id] = options[:folder_id] if options[:folder_id]

    results = api.campaigns.retrieve(params: list_params)
    results.body[:campaigns]
  rescue Gibbon::MailChimpError => e
    Rails.logger.info "=== Error sent_campaign_list for list #{mc_id} : #{e.message}"

    []
  end

  # Get simplified list of sent campaigns. Useful for showing archived
  # campaigns on the front end
  #------------------------------------------------------------------------------
  def sent_campaign_list_simple(options = { start: 0, limit: 100 })
    list = sent_campaign_list(options)
    list.map do |item|
      {
        subject:     item[:settings][:subject_line],
        title:       item[:settings][:title],
        sent_on:     item[:send_time].to_datetime,
        archive_url: item[:archive_url]
      }
    end
  end

  #------------------------------------------------------------------------------
  def folder_list(type = 'campaign')
    case type
    when 'campaign'
      result      = api.campaign_folders.retrieve
      folder_list = result.body[:folders]

      folder_list.sort! { |x, y| x[:name] <=> y[:name] }
    else
      []
    end
  end

  #------------------------------------------------------------------------------
  def map_error_to_msg(code)
    MAILCHIMP_ERRORS[code] ? "nms.#{MAILCHIMP_ERRORS[code]}" : 'nms.mc_unknown_error'
  end

  # Grab an API object to work with. This is one-time-use - you need a new
  # one for each request
  #------------------------------------------------------------------------------
  def api
    return if Account.current.preferred_nms_api_key.blank?

    Gibbon::Request.new(api_key: Account.current.preferred_nms_api_key, symbolize_keys: true)
  end

  # is the email already subscribed to this list
  #------------------------------------------------------------------------------
  def email_subscribed?(email)
    subscriber = subscriber_info(email)

    subscriber.present? && subscriber[:status] == 'subscribed'
  end

  private

  #------------------------------------------------------------------------------
  def hash_email(email)
    Digest::MD5.hexdigest(email.downcase)
  end

  #------------------------------------------------------------------------------
  def build_merge_vars(user_or_email, options)
    # remove any invalid merge vars or other options
    merge_vars = options.except('new-email', :email, :optin_ip, :optin_time, :mc_location, :mc_notes,
                                :update_existing, :mc_language, :headers)

    if user_or_email.is_a?(User)
      merge_vars[:FNAME]   = user_or_email.first_name
      merge_vars[:LNAME]   = user_or_email.last_name
      merge_vars[:COUNTRY] = user_or_email.country.english_name if user_or_email.country
    end

    merge_vars[:COUNTRY] = 'United States of America' if merge_vars[:COUNTRY] == 'United States'
    merge_vars[:SPAMAPI] = 1

    merge_vars
  end

  #------------------------------------------------------------------------------
  def build_body(email, merge_vars)
    interests = merge_vars.delete('GROUPINGS')

    body = {
      email_address:  email,
      status:         'subscribed',
      merge_fields:   merge_vars,
      language:       I18n.locale # set the language to the current locale they are using
    }

    if interests
      all_interests    = interest_ids(groupings[0][:groups]).map { |i| [i, false] }.to_h
      interests        = interests['groups'].map { |i| [i, true] }.to_h
      body[:interests] = all_interests.merge(interests)
    end

    body
  end

  # Query the lists in MailChimp, and create / update what we have in the database.
  # If a list no longer exists, we will delete it and any attached information
  # Note: [todo] This function is currently not used.  Still determining if it's needed.
  #       Keep here until final decision.
  #------------------------------------------------------------------------------
  # def self.synchronize
  #   newsletters = MailchimpNewsletter.all
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
