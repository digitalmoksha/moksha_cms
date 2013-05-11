DmEvent::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'ems' do
        resources :workshops
      end
    end

    match '/event/register/:id/new',                  :controller => 'registrations', :action => :new, :as => :register_new
    match '/event/register/:id/create',               :controller => 'registrations', :action => :create, :as => :register_create, :via => :post
    match '/event/register/success/(:receipt_code)',    :controller => 'registrations', :action => :success, :as => :register_success
  end

end
