DmForum::Engine.routes.draw do

  #--- for some reason, just having this in the main app's routes didn't work, so also added here
  themes_for_rails
  
  scope ":locale" do
    namespace :admin do
      match '/dashboard/widget_forum_comments(/:comment_day)',   :controller => 'dashboard', :action => :widget_forum_comments, :as => :widget_forum_comments
      scope 'fms' do
        resource  :forum_site
        match '/forum_categories/sort',      :controller => 'forum_categories', :action => :sort, :as => :forum_category_sort
        resources :forum_categories do
          resources :forums
        end
        match '/forums/sort',      :controller => 'forums', :action => :sort, :as => :forum_sort
        resources :forums do
          member do
            get     'forum_users',          :action => :forum_users, :as => :forum_users
            get     'forum_add_member',     :action => :forum_add_member, :as => :forum_add_member
            post    'forum_add_member',     :action => :forum_add_member, :as => :forum_add_member
            delete  'forum_delete_member',  :action => :forum_delete_member, :as => :forum_delete_member
          end
        end
      end
    end
    
    scope 'forum' do
      match '/',                            :controller => 'forums', :action => :categories, :as => :forum_root
      match '/:id',                         :controller => 'forums', :action => :show, :as => :forum_show
      resources :forums do
        resources :forum_topics do
          resources :forum_comments
          post    'toggle_follow',          :action => :toggle_follow
        end
        resources :posts
      end

      resources :forum_comments do
        get :search, :on => :collection
      end
    end
  end

end
