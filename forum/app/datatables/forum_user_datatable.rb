class ForumUserDatatable
  include ActionView::Helpers::TagHelper
  
  delegate :params, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, to: :@view
  delegate :url_helpers, to: 'DmForum::Engine.routes'
  
  #------------------------------------------------------------------------------
  def initialize(view, forum)
    @view   = view
    @forum  = forum
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
        action(user),
        user.country.nil? ? 'n/a' : user.country.english_name,
      ]
    end
  end

  #------------------------------------------------------------------------------
  def users
    @users ||= fetch_users
  end

  #------------------------------------------------------------------------------
  def fetch_users
    users = User.includes(:user_profile => [ :country ] ).references(:user_profile).order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("LOWER(user_profiles.first_name) like :search OR LOWER(user_profiles.last_name) like :search OR LOWER(users.email) like :search", search: "%#{params[:sSearch]}%".downcase)
    end
    users
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
    columns = ["LOWER(user_profiles.first_name) #{sort_direction}, LOWER(user_profiles.last_name)", 'globalize_countries.english_name']
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  #------------------------------------------------------------------------------
  def action(user)
    if @forum.member? user
      icons(:checkmark) + "&nbsp;&nbsp;".html_safe + user.full_name
    else
      link_to(icons(:add), url_helpers.forum_add_member_admin_forum_path(@forum, :locale => DmCore::Language.locale, :user_id => user.id), :title => 'Add Access') + "&nbsp;&nbsp;".html_safe + user.full_name
    end
  end
end
