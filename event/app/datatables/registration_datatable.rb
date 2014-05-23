class RegistrationDatatable
  include ActionView::Helpers::TagHelper
  include DmEvent::RegistrationsHelper
  include DmUtilities::DateHelper
  include DmCore::ApplicationHelper
  
  delegate :params, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, to: :@view
  delegate :url_helpers, to: 'DmEvent::Engine.routes'
  
  #------------------------------------------------------------------------------
  def initialize(view)
    @view = view
  end

  #------------------------------------------------------------------------------
  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalDisplayRecords: registrations.total_entries,
      iTotalRecords: @workshop.registrations.count,
      aaData: data
    }
  end

private

  #------------------------------------------------------------------------------
  def data
    registrations.map do |registration|
      [
        registration_actions(registration),
        "<span style='white-space:nowrap;'>#{registration.receipt_code}</span>",
        name_and_avatar(registration),
        workshop_price(registration),
        "<span style='white-space:nowrap;'>#{format_date(registration.created_at)}</span>",
        (registration.user_profile.user ? present(registration.user_profile.user).last_access : colored_label('no user', :gray))
      ]
    end
  end

  #------------------------------------------------------------------------------
  def registrations
    @registrations ||= fetch_registrations
  end

  #------------------------------------------------------------------------------
  def name_and_avatar(registration)
    # image_tag(registration.user_profile.public_avatar_url(:sq35), width: 25, height: 25) + link_to(registration.full_name, url_helpers.edit_admin_registration_path(I18n.locale, registration))
    link_to(registration.full_name, url_helpers.edit_admin_registration_path(I18n.locale, registration))
  end
  
  #------------------------------------------------------------------------------
  def fetch_registrations
    @workshop     = Workshop.find_by_slug(params[:id])
    registrations = @workshop.registrations.includes(:workshop_price, :user_profile => [:user => :current_site_profile]).references(:user_profiles).order("#{sort_column} #{sort_direction}")
    registrations = registrations.page(page).per_page(per_page)
    if params[:sSearch].present?
      registrations = registrations.where("LOWER(user_profiles.first_name) like :search OR LOWER(user_profiles.last_name) like :search OR LOWER(user_profiles.email) like :search OR receipt_code like :search", search: "%#{params[:sSearch]}%")
    end
    registrations
  end

  #------------------------------------------------------------------------------
  def registration_actions(registration)
    actions = ''
    actions += '<div class="btn-group">'
      actions += "<button class='btn btn-xs dropdown-toggle btn-#{registration.current_state} hovertip' data-placement='right' data-toggle='dropdown' title='#{registration.current_state.capitalize} on #{format_date(registration.process_changed_on)}'><i class='caret'></i></button>"
      actions += '<ul class="dropdown-menu">'
        actions += action_list(registration)
      actions += '</ul>'
    actions += '</div>'
  end
  
  #------------------------------------------------------------------------------
  def action_list(registration)
    actions = registration.aasm.permissible_events
    actions.sort! {|x,y| x.to_s <=> y.to_s}

    output = ''
    actions.each do |action|
      output << '<li>' +
      link_to('<i class="icon-chevron-right"></i>'.html_safe + action.to_s.titlecase, 
              url_helpers.action_state_admin_registration_path(I18n.locale, registration, :state_event => action),
              {:remote => true, :method => :put}) +
       '</li>'
     end
    return output.html_safe
  end
  
  #------------------------------------------------------------------------------
  def workshop_price(registration)
    if registration.workshop_price && registration.workshop_price.price
      color = (registration.balance_owed.cents > 0) ? 'balance_owed' : 'balance_paid'
      amount = (registration.balance_owed.cents == 0) ? 'paid' : registration.balance_owed.format(:no_cents_if_whole => true)
      "<span data-placement='left' class='hovertip #{color}' title='#{registration.workshop_price.price.format(:no_cents_if_whole => true)} &mdash; #{registration.workshop_price.price_description}'>#{amount}</span>".html_safe
    else
      '-'
    end

  end
  
  #------------------------------------------------------------------------------
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  #------------------------------------------------------------------------------
  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 50
  end

  #------------------------------------------------------------------------------
  def sort_column
    columns = ["aasm_state #{sort_direction}, process_changed_on", 'receipt_code', "LOWER(user_profiles.first_name) #{sort_direction}, LOWER(user_profiles.last_name)", '', 'ems_registrations.created_at', 'user_site_profiles.last_access_at']
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
