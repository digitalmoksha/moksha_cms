DmEvent::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'ems' do
        resources :workshops do
          member do
            get  'edit_system_email/:email_type',     :action => 'edit_system_email', :as => 'edit_system_email'
            post 'edit_system_email/:email_type',     :action => 'edit_system_email', :as => 'edit_system_email'
            put  'edit_system_email/:email_type',     :action => 'edit_system_email', :as => 'edit_system_email'
            get  'financials',                        :action => 'financials'
          end
          resources :workshop_prices
        end
        resources :registrations do
          member do
            put    'action_state/:state_event',         :action => 'action_state', :as => 'action_state'
            post   'ajax_payment',                      :action => 'ajax_payment'
            put    'ajax_edit_payment/:payment_id',     :action => 'ajax_payment', :as => 'ajax_edit_payment'
            delete 'ajax_delete_payment/:payment_id',   :action => 'ajax_delete_payment', :as => 'ajax_delete_payment'
          end
        end
        resources :workshop_prices
        match '/workshop_prices/sort',                :controller => :workshop_prices, :action => :sort, :as => :workshop_price_sort
      end
    end

    match '/event/register/:id/new',                  :controller => 'registrations', :action => :new, :as => :register_new
    match '/event/register/:id/create',               :controller => 'registrations', :action => :create, :as => :register_create, :via => :post
    match '/event/register/success/(:receipt_code)',  :controller => 'registrations', :action => :success, :as => :register_success
    match '/event/register/choose_payment/(:receipt_code)',  :controller => 'registrations', :action => :choose_payment, :as => :register_choose_payment
    match '/event/register/payments_notify',          :controller => 'registrations', :action => :payments_notify, :as => :register_payments_notify
    match '/event/register/payments_return',          :controller => 'registrations', :action => :payments_return, :as => :register_payments_return
    match '/event/register/payment_abandoned/(:receipt_code)', :controller => 'registrations', :action => :payment_abandoned, :as => :register_payment_abandoned
  end

end
