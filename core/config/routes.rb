#Rails.application.routes.prepend do 
DmCore::Engine.routes.draw do
  scope ":locale" do
    match "/profile/account",               :controller => :profile, :action => :account, :as => :edit_profile_account
    match "/profile/details",               :controller => :profile, :action => :details, :as => :edit_profile_details

    match '/admin', :controller => 'admin/dashboard', :action => :index
    namespace :admin do 
      match '/dashboard/index', :controller => 'dashboard', :action => :index, :as => 'dashboard'
      match '/dashboard/update_site_assets', :controller => 'dashboard', :action => :update_site_assets
      match '/dashboard/change_theme/:id', :controller => 'dashboard', :action => :change_theme, :as => :change_theme
      resources :users do
        member do
          get  :masquerade
        end
      end

      get  '/account/',                 to: 'accounts#show'
      get  '/account/general',          to: 'accounts#general'
      put  '/account/general',          to: 'accounts#general'
      get  '/account/email',            to: 'accounts#email'
      put  '/account/email',            to: 'accounts#email'
      get  '/account/analytics',        to: 'accounts#analytics'
      put  '/account/analytics',        to: 'accounts#analytics'
      get  '/account/metadata',         to: 'accounts#metadata'
      put  '/account/metadata',         to: 'accounts#metadata'

    end
  end
end
