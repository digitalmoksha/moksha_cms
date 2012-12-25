class UserDatatable
  include Admin::ThemeAmsterdamHelper
  
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, to: :@view
  delegate :url_helpers, to: 'DmCore::Engine.routes'
  
  #------------------------------------------------------------------------------
  def initialize(view)
    @view = view
  end

  #------------------------------------------------------------------------------
  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.total_entries,
      aaData: data
    }
  end

private

  #------------------------------------------------------------------------------
  def data
    users.map do |user|
      [
        h(user.first_name),
        h(user.last_name),
        h(user.email),
        user.country.nil? ? 'n/a' : user.country.english_name,
        user.last_access_at.nil? ? colored_label('n/a', :warning) : "#{time_ago_in_words(user.last_access_at)} ago",
        user.is_admin? ? colored_label('Admin', :success) : 'User',
        "<ul class='table-controls'>#{user_actions(user)}</ul>"
      ]
    end
  end

  #------------------------------------------------------------------------------
  def users
    @users ||= fetch_products
  end

  #------------------------------------------------------------------------------
  def fetch_products
    users = User.includes(:country).order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("first_name like :search OR last_name like :search OR email like :search", search: "%#{params[:sSearch]}%")
    end
    users
  end

  #------------------------------------------------------------------------------
  def user_actions(user)
    actions = ''
    actions << '<li>' + link_to(icons("font-edit"), url_helpers.edit_admin_user_path(user, :locale => DmCore::Language.locale), :title => 'Edit', :class => 'btn hovertip') + '</li>'
    actions << '<li>' + link_to(icons("font-remove"), url_helpers.admin_user_path(user, :locale => DmCore::Language.locale), method: :delete, data: { confirm: 'Are you sure?' }, :title => 'Remove', :class => 'btn hovertip') + '</li>'
  end
  
  #------------------------------------------------------------------------------
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  #------------------------------------------------------------------------------
  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  #------------------------------------------------------------------------------
  def sort_column
    columns = %w[first_name last_name email globalize_countries.english_name last_access_at]
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
