DmCms::Engine.routes.draw do
  scope ":locale" do

    namespace :admin do
      match '/cms_pages/expire_cache_total',                   :controller => 'cms_pages', :action => :expire_cache_total, :as => :expire_cache
      match '/cms_pages/ajax_sort',                             :controller => 'cms_pages', :action => :ajax_sort, :as => :cms_page_sort
      resources :cms_pages do
        member do
          get  :new_page
          post :create_page
          put  :duplicate_page
          post :file_tree
          get :file_tree
        end
      end

      resources :cms_contentitems do
        member do
          get  :new_content
          post :create_content
          get  :move_up
          get  :move_down
        end
      end
      resources :cms_blogs do
        resources :cms_posts
      end
      resources :cms_posts
      match '/cms_blogs/sort',                             :controller => 'cms_blogs', :action => :sort, :as => :cms_blog_sort
    end

    scope 'blog' do
      match '/',                                    :controller => 'blogs', :action => :index, :as => :blog_root
      match '/:id',                                 :controller => 'blogs', :action => :show, :as => :blog_show
      match '/:cms_blog_id/:id',                    :controller => 'posts', :action => :show, :as => :post_show
      resources :cms_blogs do
        resources :cms_posts do
          resources :cms_post_comments
        end
      end

      resources :cms_blog_comments do
        get :search, :on => :collection
      end
    end

    match '/coming_soon',                                   :controller => 'pages', :action => :show, :slug => 'coming_soon', :as  => :coming_soon
    match '/:slug(/:xaction(/:xid))',                       :controller => 'pages', :action => :show, :as  => :showpage 

  end
end
