class RegistrationDatatable
  include Admin::ThemeAmsterdamHelper
  include DmEvent::RegistrationsHelper
  include DmUtilities::DateHelper
  
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, to: :@view
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
        h(registration.receipt_code),
        h(registration.user_profile.full_name),
        workshop_price(registration),
        h(format_date(registration.created_at))
      ]
    end
  end

  #------------------------------------------------------------------------------
  def registrations
    @registrations ||= fetch_registrations
  end

  #------------------------------------------------------------------------------
  def fetch_registrations
    @workshop     = Workshop.find_by_slug(params[:id])
    registrations = @workshop.registrations.includes(:user_profile => [:country]).order("#{sort_column} #{sort_direction}")
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
      actions += "<button class='btn btn-mini dropdown-toggle btn-#{registration.current_state} hovertip' data-placement='right' data-toggle='dropdown' title='#{registration.current_state.capitalize} on #{format_date(registration.process_changed_on)}'><span class='caret'></span></button>"
      actions += '<ul class="dropdown-menu">'
        actions += action_list(registration)
      actions += '</ul>'
    actions += '</div>'
  end
  
  #------------------------------------------------------------------------------
  def action_list(registration)
    actions = registration.aasm.permissible_events
    actions.sort! {|x,y| x.to_s <=> y.to_s}

    # actions.insert(actions.size, 'Verify Payment') if event_registration.paid?
    # event_registration.confirmed? ? actions.insert(actions.size, 'UnConfirm') : actions.insert(actions.size, 'Confirm') 
    # event_registration.archived? ? actions.insert(actions.size, 'UnArchive') : actions.insert(actions.size, 'Archive') 
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
    if registration.workshop_price
      "<span data-placement='left' class='hovertip' title='#{registration.workshop_price.price_description}'>#{registration.workshop_price.price_formatted}</span>".html_safe
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
    columns = ["aasm_state #{sort_direction}, process_changed_on", 'receipt_code', "LOWER(user_profiles.first_name) #{sort_direction}, LOWER(user_profiles.last_name)", '', 'ems_registrations.created_at']
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
