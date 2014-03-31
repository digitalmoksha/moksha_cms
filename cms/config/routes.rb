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
        resources :cms_posts
      end
      resources :cms_posts do
        member do
          put     'send_notifications_emails',    action: :send_notifications_emails, as: :send_notifications_emails
        end
      end
      post   '/cms_blogs/sort',                    controller: 'cms_blogs', action: :sort, as: :cms_blog_sort
    end

    scope 'blog' do
      get   '/',                                  controller: 'blogs', action: :index, as: :blog_root
      get   '/:id',                               controller: 'blogs', action: :show, as: :blog_show
      get   '/:cms_blog_id/:id',                  controller: 'posts', action: :show, as: :post_show
      resources :cms_blogs do
        resources :cms_posts
      end
      resources :cms_posts do
        post    :ajax_add_comment,                controller: 'posts', action: :ajax_add_comment
        # get     'ajax_edit_comment/:id',          controller: 'posts', action: :ajax_edit_comment, as: :ajax_edit_comment_comment
        # post    'ajax_edit_comment/:id',          controller: 'posts', action: :ajax_edit_comment, as: :ajax_edit_comment_comment
        delete  'ajax_delete_comment/:id',        controller: 'posts', action: :ajax_delete_comment, as: :ajax_delete_comment_comment
      end
    end

    post  '/contact_form/create',                 controller: :contact_form, action: :create, as: :create_contact_form
    get   '/coming_soon',                         controller: 'pages', action: :show, slug: 'coming_soon', as: :coming_soon
    get   '/:slug(/:xaction(/:xid))',             controller: 'pages', action: :show, as: :showpage 

  end
end
