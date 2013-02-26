DmCms::Engine.routes.draw do
  scope ":locale" do

      namespace :admin do
        match '/cms_pages/expire_cache_total',                   :controller => 'cms_pages', :action => :expire_cache_total, :as => :expire_cache
        resources :cms_pages do
          member do
            get  :new_page
            post :create_page
            get  :move_up
            get  :move_down
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
      end

    match '/:slug(/:xaction(/:xid))',                       :controller => 'pages', :action => :show, :as  => :showpage 

  end
end
