DmEvent::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'ems' do
        resources :workshops do
          member do
            match 'edit_system_email/:email_type',     action: 'edit_system_email', as: 'edit_system_email', via: [:get, :post, :patch]
            get   'financials',                        action: 'financials'
            match 'lost_users',                        action: 'lost_users', via: [:get, :post, :patch]
            patch 'send_payment_reminder_emails',      action: 'send_payment_reminder_emails'
            match 'additional_configuration',          action: 'additional_configuration', via: [:get, :patch]
          end
          resources :workshop_prices
        end
        get   '/workshop/user_outstanding_balances',   controller: :workshops, action: 'user_outstanding_balances'
        resources :registrations do
          member do
            put    'action_state/:state_event',         action: 'action_state', as: 'action_state'
            post   'ajax_payment',                      action: 'ajax_payment'
            patch  'ajax_edit_payment/:payment_id',     action: 'ajax_payment', as: 'ajax_edit_payment'
            delete 'ajax_delete_payment/:payment_id',   action: 'ajax_delete_payment', as: 'ajax_delete_payment'
          end
        end
        resources :workshop_prices
        post  '/workshop_prices/sort',                  controller: :workshop_prices, action: :sort, as: :workshop_price_sort
      end
    end

    get   '/event/register/:id/new',                            controller: 'registrations', action: :new,                as: :register_new
    post  '/event/register/:id/create',                         controller: 'registrations', action: :create,             as: :register_create, via: :post
    get   '/event/register/success/(:uuid)',                    controller: 'registrations', action: :success,            as: :register_success
    get   '/event/register/choose_payment/(:uuid)',             controller: 'registrations', action: :choose_payment,     as: :register_choose_payment
    get   '/event/register/payments_return',                    controller: 'registrations', action: :payments_return,    as: :register_payments_return
    post  '/event/payment/paypal_ipn',                          controller: 'payments',      action: :paypal_ipn,         as: :payment_paypal_ipn
    post  '/event/payment/sofort_ipn',                          controller: 'payments',      action: :sofort_ipn,         as: :payment_sofort_ipn
  end

end
