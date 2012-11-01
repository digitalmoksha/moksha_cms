#Rails.application.routes.prepend do 
DmCore::Engine.routes.draw do
  scope ":locale" do
    namespace :admin do 
      match '/dashboard/index', :controller => 'dashboard', :action => :index, :as => 'dashboard'
      resources :users
    end
  end
end
