DmCms::Engine.routes.draw do
  scope ":locale" do

    namespace :admin do
      patch '/cms_pages/expire_cache_total',                    controller: 'cms_pages', action: :expire_cache_total, as: :expire_cache
      post  '/cms_pages/ajax_sort',                             controller: 'cms_pages', action: :ajax_sort, as: :cms_page_sort
      get   '/dashboard/widget_blog_comments(/:comment_day)',   controller: 'dashboard', action: :widget_blog_comments, as: :widget_blog_comments
      resources :cms_pages do
        member do
          get  :new_page
          post :create_page
          put  :duplicate_page
          post :file_tree
          get :file_tree
        end
      end

      resources :cms_contentitems do
        member do
          get    :new_content
          post   :create_content
          patch  :move_up
          patch  :move_down
          get    :markdown
          post   :markdown
        end
      end
      resources :cms_snippets
      resources :cms_blogs do
        member do
          get     'blog_users',          action: :blog_users, as: :blog_users
          match   'blog_add_member',     action: :blog_add_member, as: :blog_add_member, via: [:get, :post]
          delete  'blog_delete_member',  action: :blog_delete_member, as: :blog_delete_member
        end
        resources :cms_posts do
          member do
            put     'send_notifications_emails',    action: :send_notifications_emails, as: :send_notifications_emails
          end
        end
      end
      # resources :cms_posts do
      #   member do
      #     put     'send_notifications_emails',    action: :send_notifications_emails, as: :send_notifications_emails
      #   end
      # end
      post   '/cms_blogs/sort',                    controller: 'cms_blogs', action: :sort, as: :cms_blog_sort
      resources :media_files
    end

    scope 'blog' do
      get   '/recent_posts',                      controller: 'blogs', action: :index, as: :blog_root
      get   '/:id',                               controller: 'blogs', action: :show, as: :blog_show
      get   '/:cms_blog_id/:id',                  controller: 'posts', action: :show, as: :post_show
      resources :cms_blogs do
        post    '/cms_posts/ajax_add_comment/:id',   controller: 'posts', action: :ajax_add_comment, as: :cms_post_ajax_add_comment
        # get  '/cms_posts/ajax_edit_comment/:id', controller: 'posts', action: :ajax_edit_comment, as: :cms_postajax_edit_comment_comment
        resources :cms_posts
        patch    'toggle_follow',                 controller: 'blogs', action: :toggle_follow
      end
      resources :cms_posts do
        delete  'ajax_delete_comment/:id',        controller: 'posts', action: :ajax_delete_comment, as: :ajax_delete_comment_comment
      end
    end

    post  '/contact_form/create',                 controller: :contact_form, action: :create, as: :create_contact_form
    get   '/coming_soon',                         controller: 'pages', action: :show, slug: 'coming_soon', as: :coming_soon
    get   '/*slug(/:xaction(/:xid))',             controller: 'pages', action: :show, as: :showpage  # use *slug to fix this https://github.com/rails/rails/issues/16058

  end
end
