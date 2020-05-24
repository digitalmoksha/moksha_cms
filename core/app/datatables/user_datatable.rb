class UserDatatable
  include ActionView::Helpers::TagHelper
  include DmCore::ApplicationHelper

  delegate :params, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, to: :@view
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
        (link_to present(user).avatar_for(35, class: 'img-circle'), user.user_profile.public_avatar_url).to_s,
        link_to(user.full_name.to_s_default, url_helpers.edit_admin_user_path(user, locale: DmCore::Language.locale), title: "Edit #{user.full_name}"),
        user.email,
        user.country.nil? ? 'n/a' : user.country.english_name,
        "<span style='white-space:nowrap'>#{present(user).last_access}</span>",
        present(user).role_label
      ]
    end
  end

  #------------------------------------------------------------------------------
  def users
    @users ||= fetch_users
  end

  #------------------------------------------------------------------------------
  def fetch_users
    users = User.current_account_users.includes({ user_profile: [:country] })
    users = users.order(Arel.sql("#{sort_column} #{sort_direction}"))
    users = users.page(page).per_page(per_page)
    users = users.where("LOWER(user_profiles.first_name) like :search OR LOWER(user_profiles.last_name) like :search OR LOWER(users.email) like :search", search: "%#{params[:sSearch]}%".downcase) if params[:sSearch].present?
    users
  end

  #------------------------------------------------------------------------------
  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  #------------------------------------------------------------------------------
  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 50
  end

  #------------------------------------------------------------------------------
  def sort_column
    columns = ['', "LOWER(user_profiles.first_name) #{sort_direction}, LOWER(user_profiles.last_name)", 'LOWER(user_profiles.email)', 'globalize_countries.english_name', 'user_site_profiles.last_access_at']
    columns[params[:iSortCol_0].to_i]
  end

  #------------------------------------------------------------------------------
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
