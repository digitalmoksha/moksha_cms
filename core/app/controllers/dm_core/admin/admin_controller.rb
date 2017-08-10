# This controller is a base class for all other admin controllers
# scope_current_account gets called through the eventual inheritacne of DmCore::ApplicationController
#------------------------------------------------------------------------------
class DmCore::Admin::AdminController < ApplicationController

  before_action :authenticate_admin_user!
  before_action :setup_admin_data
  before_action :template_setup

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
    unless can?(:access_admin, :all)
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
          if is_sysadmin?
            item[:children] << {text: 'Clear All Page Caches', icon_class: :undo, link: dm_cms.admin_expire_cache_total_path, link_options: {method: :patch} }
          end
        end
        @admin_theme[:top_menu] << item
        
        item[:children] << {text: 'Site Settings', icon_class: :gear,   link: dm_core.admin_account_path } if is_admin?
        item[:children] << {text: 'System Admin',  icon_class: :wrench, link: dm_core.admin_system_path }  if is_sysadmin?
      end

      #--- User menu
      item = { text: current_user.display_name, icon_class: :user, children: [], link: '#' }
      item[:children] << {text: 'My profile',   icon_class: :user, link: dm_core.edit_profile_account_path }
      item[:children] << {text: 'Logout',       icon_class: :exit, link: main_app.destroy_user_session_path, link_options: {method: :delete} }
      @admin_theme[:top_menu] << item
       
      #=== Main Menu
      @admin_theme[:main_menu] << {text: 'Dashboard', icon_class: :dashboard, link: dm_core.admin_dashboard_path }
      @admin_theme[:main_menu] |= DmCms::AdminMenuInject.menu_items(current_user)           if defined?(DmCms)
      @admin_theme[:main_menu] |= DmEvent::AdminMenuInject.menu_items(current_user)         if defined?(DmEvent)
      @admin_theme[:main_menu] |= DmLms::AdminMenuInject.menu_items(current_user)           if defined?(DmLms)
      @admin_theme[:main_menu] |= DmForum::AdminMenuInject.menu_items(current_user)         if defined?(DmForum)
      @admin_theme[:main_menu] |= DmNewsletter::AdminMenuInject.menu_items(current_user)    if defined?(DmNewsletter)
      @admin_theme[:main_menu] |= DmSubscriptions::AdminMenuInject.menu_items(current_user) if defined?(DmSubscriptions)

      # give main application a chance to add anything it wants
      if self.respond_to? :admin_specific_menus
        self.admin_specific_menus @admin_theme
      end

      if defined?(::AdminMenuInject)
        @admin_theme[:main_menu] |= ::AdminMenuInject.menu_items(current_user)
      end

      if Rails.application.config.action_mailer.delivery_method == :letter_opener_web
        @admin_theme[:main_menu] << {text: 'Letter Opener', icon_class: :mail, link: main_app.letter_opener_web_path }
      end

      # set the active state to true if the path matches
      @admin_theme[:main_menu].each do |item|
        item[:active] = admin_path_active_class?(item[:active_links] || item[:link]) if item[:link] && item[:link] != '#'
        if item[:children]
          item[:children].each do |child|
            child[:active] = admin_path_active_class?(child[:active_links] || child[:link]) if child[:link] && child[:link] != '#'
          end
        end
      end

    end
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    # to be overridden by other controllers
  end

end