Rails.application.routes.draw do

  scope ":locale" do
    devise_for :users, controllers: { registrations: "registrations", confirmations: 'confirmations' }
  end

  themes_for_rails

  mount DmCore::Engine,  at: '/'
  mount DmNewsletter::Engine, at: '/'
  
end
