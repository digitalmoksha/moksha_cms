#Rails.application.routes.prepend do 
DmCore::Engine.routes.draw do
  scope ':locale' do
    match '/profile/account',               controller: :profile, action: :account, as: :edit_profile_account, via: [:get, :patch]
    match '/profile/details',               controller: :profile, action: :details, as: :edit_profile_details, via: [:get, :patch]

    get   '/admin', controller: 'admin/dashboard', action: :index
    namespace :admin do 
      get   '/dashboard/index', controller: 'dashboard', action: :index, as: 'dashboard'
      patch '/dashboard/update_site_assets', controller: 'dashboard', action: :update_site_assets
      patch '/dashboard/change_theme/:id', controller: 'dashboard', action: :change_theme, as: :change_theme
      resources :users do
        member do
          get  :masquerade
          get  :confirm
        end
      end
      resources :comments

      get     '/account/',                 to: 'accounts#show'
      match   '/account/general',          to: 'accounts#general',    via: [:get, :patch]
      match   '/account/email',            to: 'accounts#email',      via: [:get, :patch]
      match   '/account/analytics',        to: 'accounts#analytics',  via: [:get, :patch]
      match   '/account/metadata',         to: 'accounts#metadata',   via: [:get, :patch]
      match   '/account/media',            to: 'accounts#media',   via: [:get, :patch]

    end
  end
end
