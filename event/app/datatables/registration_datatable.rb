class RegistrationDatatable
  include Admin::ThemeAmsterdamHelper
  
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
        h(registration.receipt_code),
        h(registration.user.full_name),
        h(registration.user.email),
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
    registrations = @workshop.registrations.includes(:user).order("#{sort_column} #{sort_direction}")
    registrations = registrations.page(page).per_page(per_page)
    if params[:sSearch].present?
      registrations = registrations.where("users.first_name like :search OR users.last_name like :search OR users.email like :search OR receipt_code like :search", search: "%#{params[:sSearch]}%")
    end
    registrations
  end

  #------------------------------------------------------------------------------
  def registration_actions(registration)
    actions = ''
    # actions << '<li>' + link_to(icons("font-edit"), url_helpers.edit_admin_user_path(user, :locale => DmCore::Language.locale), :title => 'Edit', :class => 'btn hovertip') + '</li>'
    # actions << '<li>' + link_to(icons("font-remove"), url_helpers.admin_user_path(user, :locale => DmCore::Language.locale), method: :delete, data: { confirm: 'Are you sure?' }, :title => 'Remove', :class => 'btn hovertip') + '</li>'
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
    columns = ['receipt_code', "LOWER(users.first_name) #{sort_direction}, LOWER(users.last_name)", 'users.email']
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
