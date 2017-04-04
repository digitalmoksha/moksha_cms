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

      get     '/account/new_account',       to: 'accounts#new_account',                     as: :account_new
      post    '/account/create_account',    to: 'accounts#create_account',                  as: :account_create
      match   '/account/:id/general',       to: 'accounts#general',    via: [:get, :patch], as: :account_general
      match   '/account/:id/email',         to: 'accounts#email',      via: [:get, :patch], as: :account_email
      match   '/account/:id/analytics',     to: 'accounts#analytics',  via: [:get, :patch], as: :account_analytics
      match   '/account/:id/metadata',      to: 'accounts#metadata',   via: [:get, :patch], as: :account_metadata
      match   '/account/:id/media',         to: 'accounts#media',      via: [:get, :patch], as: :account_media
      get     '/account/(:id)',             to: 'accounts#show',                            as: :account

      get     '/system/',                   to: 'system#show'
      get     '/setup/initial_setup',       to: 'setup#initial_setup'
      match   '/setup/step1',               to: 'setup#step1',         via: [:get, :post]
      match   '/setup/step2',               to: 'setup#step2',         via: [:get, :post]

    end
  end
end
