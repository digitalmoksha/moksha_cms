#Rails.application.routes.prepend do 
DmCore::Engine.routes.draw do
  scope ":locale" do
    namespace :admin do 
      match '/dashboard/index', :controller => 'dashboard', :action => :index, :as => 'dashboard'
      match '/dashboard/update_site_assets', :controller => 'dashboard', :action => :update_site_assets
      resources :users
    end
  end
end
