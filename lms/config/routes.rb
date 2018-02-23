DmLms::Engine.routes.draw do
  scope ":locale" do
    post '/lesson_pages/ajax_add_comment',          controller: 'lesson_pages', action: :ajax_add_comment, as: :lesson_page_add_comment
    delete '/lesson_pages/ajax_delete_comment/:id', controller: 'lesson_pages', action: :ajax_delete_comment, as: :lesson_page_delete_comment
    namespace :admin do
      get '/dashboard/widget_lesson_comments(/:comment_day)',   controller: 'dashboard', action: :widget_lesson_comments, as: :widget_lesson_comments
      scope 'lms' do
        # --- simplifying nested resources, from http://weblog.jamisbuck.org/2007/2/5/nesting-resources
        post '/courses/sort',           controller: 'courses', action: :sort, as: :course_sort
        resources :courses do
          resources :lessons
        end
        post '/lessons/sort',           controller: 'lessons', action: :sort, as: :lesson_sort
        resources :lessons
        resources :lessons do
          resources :lesson_pages
          resources :teachings
        end
        post '/lesson_pages/sort',      controller: 'lesson_pages', action: :sort, as: :lesson_page_sort
        resources :lesson_pages
        resources :teachings
      end
    end

    scope 'learn' do
      resources :lesson_pages do
        post    :ajax_add_comment,                        controller: 'lesson_pages', action: :ajax_add_comment
        delete  'ajax_delete_comment/:id',                controller: 'lesson_pages', action: :ajax_delete_comment, as: :ajax_delete_comment_comment
      end

      get   '/courses',                                   controller: 'courses', action: :index, as: :course_index
      get   '/:course_slug',                              controller: 'courses', action: :show, as: :course_show
      get   '/:course_slug/:lesson_slug',                 controller: 'lessons', action: :show, as: :lesson_show
      get   '/:course_slug/:lesson_slug/:content_slug',   controller: 'lesson_pages', action: :show, as: :lesson_page_show
    end
  end
end
