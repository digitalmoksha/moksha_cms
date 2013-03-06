#Rails.application.routes.prepend do 
DmCore::Engine.routes.draw do
  scope ":locale" do
    match '/admin', :controller => 'admin/dashboard', :action => :index
    namespace :admin do 
      match '/dashboard/index', :controller => 'dashboard', :action => :index, :as => 'dashboard'
      match '/dashboard/update_site_assets', :controller => 'dashboard', :action => :update_site_assets
      match '/dashboard/change_theme/:id', :controller => 'dashboard', :action => :change_theme, :as => :change_theme
      resources :users
      resource :account
    end
  end
end
