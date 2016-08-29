Rails.application.routes.draw do

  scope ":locale" do
    devise_for :users, controllers: { registrations: "registrations", confirmations: 'confirmations' }
  end

  themes_for_rails

  mount DmCore::Engine, :at => '/'
  mount DmCms::Engine => "/dm_cms"
  
  scope ":locale" do
    get   '/index',                 controller: 'dm_cms/pages', action: :show, slug: 'index', as: :index
  end
  
  #--- use match instead of root to fix issue where sometimes '?locale=de' is appeneded
  get   '/(:locale)',            :controller => 'dm_cms/pages', :action => :show, :slug => 'index', :as => :root
  
end
