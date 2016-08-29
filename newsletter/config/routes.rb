DmNewsletter::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'nms' do
        patch '/newsletters/synchronize_lists',   :controller => :newsletters, :action => :synchronize_lists
        resources :newsletters
      end
    end

    post   '/newsletter/subscribe_to_newsletter/:token',     :controller => :newsletters, :action => :subscribe_to_newsletter, :as => :subscribe_to_newsletter
    delete '/newsletter/unsubscribe_from_newsletter/:token', :controller => :newsletters, :action => :unsubscribe_from_newsletter, :as => :unsubscribe_from_newsletter
  end

end
