# This controller is a base class for all other admin controllers
# scope_current_account gets called through the eventual inheritacne of DmCore::ApplicationController
#------------------------------------------------------------------------------
class DmCore::Admin::AdminController < ApplicationController

  before_filter :authenticate_admin_user!
  before_filter :setup_admin_data
  before_filter :template_setup

  layout 'admin_theme/admin'
  
  include DmCore::ApplicationHelper
  include DmCore::AccountHelper
  include DmCore::Admin::ApplicationHelper
  include AdminTheme::ThemeHelper

  helper  DmAdmin::ApplicationHelper
  helper  AdminTheme::ThemeHelper

  # Make sure some type of administrative user is logged in
  #------------------------------------------------------------------------------
  def authenticate_admin_user!
    authenticate_user! 
    unless can?(:access_event_section, :all) || can?(:access_admin, :all)
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end  

private

  # Initialize the data needed by the admin theme - menus, etc.  This way it can
  # be rendered differently by different admin themes.
  #------------------------------------------------------------------------------
  def setup_admin_data
    # not needed if it's an ajax call
    if !request.xhr?
      @admin_theme              = {}
      @admin_theme[:brand]      = current_account.domain
      @admin_theme[:brand_link] = main_app.index_url
      @admin_theme[:top_menu]   = []
      @admin_theme[:main_menu]  = []
      
      #=== Top Menu
      #--- Users
      item = {text: ' ', icon_class: :users, badge: User.current_account_users.count, link: (can?(:manage, :all) ? dm_core.admin_users_path : '#')}
      @admin_theme[:top_menu] << item
      
      #--- Gear menu
      if is_admin? || can?(:manage_content, :all)
        item = { text: '', icon_class: :gear, children: [], link: '#' }
        if defined?(DmCms) && can?(:manage_content, :all)
          item[:children] << {text: 'Clear Page Cache', icon_class: :undo, link: dm_cms.admin_expire_cache_path, link_options: {method: :patch} }
        end
        @admin_theme[:top_menu] << item
        
        if is_admin?
          item[:children] << {text: 'Site Settings', icon_class: :gear, link: dm_core.admin_account_path }
        end
        
        if is_sysadmin?
          item[:children] << {text: 'Update Assets', icon_class: :refresh, link: dm_core.admin_dashboard_update_site_assets_url, link_options: {method: :patch} }
        end
        
        if is_sysadmin?
          item[:children] << {text: 'System Admin', icon_class: :wrench, link: dm_core.admin_system_path }
        end
      end

      #--- User menu
      item = { text: current_user.display_name, icon_class: :user, children: [], link: '#' }
      item[:children] << {text: 'My profile', icon_class: :user, link: dm_core.edit_profile_account_path }
      item[:children] << {text: 'Logout', icon_class: :exit, link: main_app.destroy_user_session_path, link_options: {method: :delete} }
      @admin_theme[:top_menu] << item
       
      #=== Main Menu
      @admin_theme[:main_menu] << {text: 'Dashboard', icon_class: :dashboard, link: dm_core.admin_dashboard_path, active: admin_path_active_class?(dm_core.admin_dashboard_path) }

      if defined?(DmCms)
        if can?(:manage_content, :all)
          @admin_theme[:main_menu] << {text: 'Pages',         icon_class: :pages,         link: dm_cms.admin_cms_pages_path,   active: admin_path_active_class?(dm_cms.admin_cms_pages_path, dm_cms.admin_cms_snippets_path) }
          @admin_theme[:main_menu] << {text: 'Blogs',         icon_class: :blogs,         link: dm_cms.admin_cms_blogs_path,   active: admin_path_active_class?(dm_cms.admin_cms_blogs_path) }
        end
        if can?(:access_media_library, :all)
          @admin_theme[:main_menu] << {text: 'Media Library', icon_class: :media_library, link: dm_cms.admin_media_files_path, active: admin_path_active_class?(dm_cms.admin_media_files_path) }
        end
      end

      if defined?(DmEvent) && can?(:access_event_section, :all)
        item = { text: 'Events', icon_class: :events, children: [], link: '#' }
        item[:children] << {text: 'Overview', link: dm_event.admin_workshops_path,   active: admin_path_active_class?(dm_event.admin_workshops_path) }
        Workshop.upcoming.each do |workshop|
          if can?(:list_events, workshop)
            item[:children] << {text: workshop.title, badge: workshop.registrations.number_of(:attending), link: dm_event.admin_workshop_path(workshop),   active: admin_path_active_class?(dm_event.admin_workshop_path(workshop)) }
          end
        end
        @admin_theme[:main_menu] << item
      end

      if defined?(DmLms) && can?(:manage_coursed, :all)
        item = { text: 'Lexicon', icon_class: :lexicon, children: [], link: '#' }
        item[:children] << {text: 'Lexicon',        link: dm_lms.admin_lexicons_path,               active: admin_path_active_class?(dm_lms.admin_lexicons_path) }
        item[:children] << {text: 'Categories',     link: dm_lms.admin_lexicon_categories_path,     active: admin_path_active_class?(dm_lms.admin_lexicon_categories_path) }
        item[:children] << {text: 'Sub Categories', link: dm_lms.admin_lexicon_sub_categories_path, active: admin_path_active_class?(dm_lms.admin_lexicon_sub_categories_path) }
        item[:children] << {text: 'Genres',         link: dm_lms.admin_lexicon_genres_path,         active: admin_path_active_class?(dm_lms.admin_lexicon_genres_path) }
        @admin_theme[:main_menu] << item

        item = { text: 'Courses', icon_class: :courses, children: [], link: '#' }
        item[:children] << {text: 'Courses',        link: dm_lms.admin_courses_path,                active: admin_path_active_class?(dm_lms.admin_courses_path) }
        item[:children] << {text: 'Practice Sets',  link: dm_lms.admin_practice_sets_path,          active: admin_path_active_class?(dm_lms.admin_practice_sets_path) }
        @admin_theme[:main_menu] << item
      end

      if defined?(DmForum) && can?(:manage_forums, :all)
        @admin_theme[:main_menu] << {text: 'Forums', icon_class: :forums, link: dm_forum.admin_forum_categories_path, active: admin_path_active_class?(dm_forum.admin_forum_categories_path, dm_forum.admin_forums_path) }
      end

      if defined?(DmNewsletter) && can?(:manage_newsletters, :all)
        @admin_theme[:main_menu] << {text: 'Newsletter', icon_class: :newsletters, link: dm_newsletter.admin_newsletters_path, active: admin_path_active_class?(dm_newsletter.admin_newsletters_path) }
      end

      if defined?(DmSubscriptions) && can?(:manage_subscriptions, :all)
        @admin_theme[:main_menu] << {text: 'Subscriptions', icon_class: :subscriptions, link: dm_subscriptions.admin_subscription_plans_path, active: admin_path_active_class?(dm_subscriptions.admin_subscription_plans_path) }
      end

      #--- give main application a chance to add anything it wants
      if self.respond_to? :admin_specific_menus
        self.admin_specific_menus @admin_theme
      end
    end
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    # to be overridden by other controllers
  end

end