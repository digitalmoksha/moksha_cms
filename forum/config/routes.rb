DmForum::Engine.routes.draw do

  #--- for some reason, just having this in the main app's routes didn't work, so also added here
  themes_for_rails
  
  scope ":locale" do
    namespace :admin do
      scope 'fms' do
        resource  :forum_site
        match '/forums/sort',      :controller => 'forums', :action => :sort, :as => :forum_sort
        resources :forums
        
        # --- simplifying nested resources, from http://weblog.jamisbuck.org/2007/2/5/nesting-resources
        # match '/courses/sort',      :controller => 'courses', :action => :sort, :as => :course_sort
        # resources :courses do
        #   resources :lessons
        # end
        # match '/lessons/sort',      :controller => 'lessons', :action => :sort, :as => :lesson_sort
        # resources :lessons
        # resources :lessons do
        #   resources :lesson_pages
        #   resources :quizzes
        #   resources :teachings
        # end
        # match '/lesson_pages/sort',      :controller => 'lesson_pages', :action => :sort, :as => :lesson_page_sort
        # resources :lesson_pages
        # resources :quizzes
        # resources :teachings
      end
    end
    
    scope 'forum' do
      match '/',                                    :controller => 'forums', :action => :list, :as => :forum_root
      match '/:id',                                 :controller => 'forums', :action => :show, :as => :forum_show
      resources :forums do
        resources :forum_topics do
          resources :forum_comments
          resource :monitorship
        end
        resources :posts
      end

      resources :forum_comments do
        get :search, :on => :collection
      end
    end
  end

end
