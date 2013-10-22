DmNewsletter::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'nms' do
        match '/newsletters/synchronize_lists',   :controller => :newsletters, :action => :synchronize_lists
        resources :newsletters
      end
    end

    match '/newsletter/subscribe_to_newsletter/:token',     :controller => :newsletters, :action => :subscribe_to_newsletter, :as => :subscribe_to_newsletter,   :via => :post
    match '/newsletter/unsubscribe_from_newsletter/:token', :controller => :newsletters, :action => :unsubscribe_from_newsletter, :as => :unsubscribe_from_newsletter, :via => :delete
  end

end
