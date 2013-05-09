DmEvent::Engine.routes.draw do

  scope ":locale" do
    namespace :admin do
      scope 'ems' do
        resources :workshops
      end
    end
    
    # scope 'forum' do
    #   match '/',                                    :controller => 'forums', :action => :categories, :as => :forum_root
    #   match '/:id',                                 :controller => 'forums', :action => :show, :as => :forum_show
    #   resources :forums do
    #     resources :forum_topics do
    #       resources :forum_comments
    #       resource :monitorship
    #     end
    #     resources :posts
    #   end
    # 
    #   resources :forum_comments do
    #     get :search, :on => :collection
    #   end
    # end
  end

end
