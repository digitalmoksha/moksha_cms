class Workshop < ApplicationRecord
  include DmCore::Concerns::DefinesCustomFields

  self.table_name = 'ems_workshops'

  belongs_to              :country, class_name: 'DmCore::Country'
  has_many                :registrations, dependent: :destroy
  has_many                :workshop_prices, dependent: :destroy
  has_many                :system_emails,     { as: :emailable, dependent: :destroy }
  has_one                 :pending_email,     -> { where("email_type LIKE 'pending'") },    class_name: 'SystemEmail', as: :emailable
  has_one                 :accepted_email,    -> { where("email_type LIKE 'accepted'") },   class_name: 'SystemEmail', as: :emailable
  has_one                 :rejected_email,    -> { where("email_type LIKE 'rejected'") },   class_name: 'SystemEmail', as: :emailable
  has_one                 :paid_email,        -> { where("email_type LIKE 'paid'") },       class_name: 'SystemEmail', as: :emailable
  has_one                 :waitlisted_email,  -> { where("email_type LIKE 'waitlisted'") }, class_name: 'SystemEmail', as: :emailable
  has_one                 :reviewing_email,   -> { where("email_type LIKE 'reviewing'") },  class_name: 'SystemEmail', as: :emailable
  has_one                 :canceled_email,    -> { where("email_type LIKE 'canceled'") },   class_name: 'SystemEmail', as: :emailable
  has_one                 :refunded_email,    -> { where("email_type LIKE 'refunded'") },   class_name: 'SystemEmail', as: :emailable
  has_one                 :noshow_email,      -> { where("email_type LIKE 'noshow'") },     class_name: 'SystemEmail', as: :emailable
  has_one                 :cms_blog, as: :owner
  has_one                 :forum, as: :owner if defined?(DmLms)
  has_one                 :course, as: :owner if defined?(DmLms)

  # --- globalize
  translates              :title, :description, :summary, :sidebar, fallbacks_for_empty_translations: true
  globalize_accessors     locales: I18n.available_locales

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  acts_as_taggable
  resourcify

  # --- validations
  validates_presence_of   :country_id
  validates_presence_of   :base_currency
  validates_presence_of   :starting_on
  validates_presence_of   :ending_on
  validates_presence_of   :contact_email
  validates_presence_of   :event_style
  validates               :title, presence_default_locale: true
  validates               :description, liquid: { locales: true }, presence_default_locale: true
  validates               :sidebar, liquid: { locales: true }
  validates_length_of     :slug, maximum: 255
  validates_length_of     :contact_email, maximum: 60
  validates_length_of     :contact_phone, maximum: 20
  validates_length_of     :info_url, maximum: 255
  validates_length_of     :event_style, maximum: 255
  validates_length_of     :image, maximum: 255
  validates_length_of     :header_accent_color, maximum: 255
  I18n.available_locales.each do |locale|
    validates_length_of :"title_#{locale}", maximum: 255
  end

  # validates_presence_of   :deadline_on

  default_scope { where(account_id: Account.current.id) }

  scope :published,    -> { where(published: true).not_archived }
  scope :archived,     -> { where('archived_on IS NOT NULL') }
  scope :not_archived, -> { where('archived_on IS NULL') }

  # upcoming and past are used in the admin, so should be published and non-published
  scope :upcoming,     -> { where('ending_on > ?', Date.today.beginning_of_day.to_s).not_archived.order('starting_on DESC').includes(:translations) }
  scope :past,         -> { where('ending_on <= ?', Date.today.beginning_of_day.to_s).not_archived.order('starting_on DESC').includes(:translations) }

  # available is list of published and registration open and not ended
  scope :available,    -> { where('(deadline_on > ? OR deadline_on IS NULL)', Time.now.to_s).published.upcoming.order('starting_on ASC') }

  # don't use allow_nil, as this will erase the base_currency field if no funding_goal is set
  monetize             :funding_goal_cents, with_model_currency: :base_currency

  EVENT_STYLES = [['Workshop', 'workshop'], ['Crowdfunding', 'crowdfunding']].freeze

  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  # If the total_available is nil, then there are unlimited tickets to be sold.
  # Otherwise, check if we have sold out
  #------------------------------------------------------------------------------
  def price_sold_out?(workshop_price)
    # p.sold_out?(@workshop.event_registration.number_of(:registrations_by_paymenttype, payment_id: p.id)
    false # TODO
  end

  # Is the workshop visible?
  #------------------------------------------------------------------------------
  def visible?
    published? && !(past? || archived? || registration_closed?)
  end

  # Is this workshop in the past?
  #------------------------------------------------------------------------------
  def past?
    ending_on < Time.now
  end

  # Is the registration closed?  If deadline is null, then registration is open ended
  #------------------------------------------------------------------------------
  def registration_closed?
    !published? || (deadline_on ? (deadline_on < Time.now.to_date) : false)
  end

  #------------------------------------------------------------------------------
  def published?
    published
  end

  # toggle the archive state of the workshop
  #------------------------------------------------------------------------------
  def toggle_archive
    archived_on ? update_attribute(:archived_on, nil) : update_attribute(:archived_on, Time.now)
  end

  #------------------------------------------------------------------------------
  def archived?
    archived_on ? true : false
  end

  #------------------------------------------------------------------------------
  def crowdfunding?
    event_style == 'crowdfunding'
  end

  # Return financial summary and details
  # level => :summary or :detail
  #------------------------------------------------------------------------------
  def financial_details(level = :detail)
    #--- pick currency of first price
    financials = { summary: { total_possible: Money.new(0, base_currency), total_possible_worst: Money.new(0, base_currency),
                              total_paid: Money.new(0, base_currency),              total_outstanding: Money.new(0, base_currency),
                              total_outstanding_worst: Money.new(0, base_currency), total_discounts: Money.new(0, base_currency),
                              total_paid_percent: 0 },
                   collected: {},
                   collected_monthly: {},
                   payment_type: {},
                   projected: {} }

    registrations.attending.includes(:workshop_price).each do |registration|
      next unless registration.workshop_price

      #--- Calculate the summary values
      financials[:summary][:total_possible]     += registration.discounted_price
      financials[:summary][:total_paid]         += registration.amount_paid.nil? ? Money.new(0, base_currency) : registration.amount_paid
      financials[:summary][:total_outstanding]  += registration.balance_owed
      financials[:summary][:total_discoutns]    += registration.discount
    end

    if level == :detail
      registrations.attending.includes(:workshop_price, :payment_histories).each do |registration|
        next unless registration.workshop_price

        #--- Calculate what has been collected, by payment method
        registration.payment_histories.each do |payment_history|
          payment_method = payment_history.payment_method.titlecase
          financials[:collected][payment_method.to_s] = Money.new(0, base_currency) if financials[:collected][payment_method.to_s].nil?
          financials[:collected][payment_method.to_s] += payment_history.total

          month = payment_history.payment_date.beginning_of_month
          financials[:collected_monthly][month] = Money.new(0, base_currency) if financials[:collected_monthly][month].nil?
          financials[:collected_monthly][month] += payment_history.total
        end
      end
    end

    #--- give a worst case value - reduce by 20%
    financials[:summary][:total_possible_worst]               = financials[:summary][:total_possible] * 0.80
    financials[:summary][:total_outstanding_worst]            = financials[:summary][:total_outstanding] * 0.80
    financials[:summary][:total_paid_percent]                 = (100 * financials[:summary][:total_paid] / financials[:summary][:total_possible]).round if financials[:summary][:total_possible].positive?
    financials
  end

  #------------------------------------------------------------------------------
  def total_paid
    total_paid = Money.new(0, base_currency)
    registrations.attending.each do |registration|
      if registration.workshop_price
        total_paid += registration.amount_paid.nil? ? Money.new(0, base_currency) : registration.amount_paid
      end
    end
    total_paid
  end

  # is the passed in user attending?  Used in some deep level authorization checks,
  # which rely on the "member?" method.
  # This does not consider a userless registration as a "member", since there is
  # no way they can login
  #------------------------------------------------------------------------------
  def member?(user)
    registrations.attending.where(user_profile_id: user.user_profile.id).count > 0
  end

  # Provide a list of users that are members (does not include userless registrations)
  #------------------------------------------------------------------------------
  def member_count
    registrations.attending.joins(user_profile: [:user]).references(:user_profile).where('user_profiles.user_id IS NOT NULL').count
  end

  # Return list of Users that are attending (does not include userless registrations)
  #------------------------------------------------------------------------------
  def member_list
    User.includes(:user_profile).references(:user_profile).where(user_profiles: { id: registrations.attending.map(&:user_profile_id) })
  end

  #------------------------------------------------------------------------------
  def header_image(default = nil)
    image || default
  end

  #------------------------------------------------------------------------------
  def header_accent_color(default = '')
    self[:header_accent_color] || default
  end

  # Find list of newly createdusers that have not registered for any events, between
  # the end of the workshop and up to 60 day before the start of the workshop.
  # Not perfect, since people can register just to access special
  # content.  But gives rough idea of people creating an account but not realizing
  # they need to register for the event they want to participate in.
  #------------------------------------------------------------------------------
  def lost_users(days_ago = 10)
    lost = []
    new_users = User.where(created_at: (starting_on - days_ago.day)..ending_on, account_id: Account.current.id)
    new_users.each do |user|
      next unless user.user_site_profiles.where(account_id: Account.current.id)

      lost << user if user.user_profile.registrations.count == 0
    end
    lost
  end

  # return a list of tags for all Blog post objects
  #------------------------------------------------------------------------------
  def self.tag_list_all
    Workshop.tag_counts_on(:tags).map(&:name).sort
  end
end
