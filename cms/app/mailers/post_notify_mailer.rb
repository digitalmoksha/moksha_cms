class PostNotifyMailer < DmCore::SiteMailer
  
  helper  DmCms::PostsHelper
  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper

  layout 'email_templates/dm_cms_email_layout'

  # send notification email, using the users preferred locale if possible
  #------------------------------------------------------------------------------
  def post_notify(user, post, account)
    Account.current               = account  # needed so this can run in a background job
    locale                        = account.verify_locale(user.locale)
    I18n.with_locale(locale) do
      @subject                    = "Blog: #{post.cms_blog.title} :: #{post.title}"
      @recipients                 = user.email
      @blog_title                 = post.cms_blog.title
      @post_title                 = post.title
      @post_link                  = dm_cms.post_show_url(post.cms_blog.slug, post.slug, locale: locale)
      @post                       = post
      @header_image               = post.cms_blog.image_email_header || post.cms_blog.header_image

      headers = { "Return-Path" => account.preferred_blog_from_email || account.preferred_smtp_from_email }
      mail( from: account.preferred_blog_from_email || account.preferred_smtp_from_email,
            reply_to: account.preferred_blog_from_email || account.preferred_smtp_from_email,
            to: @recipients, subject: @subject,
            theme: account.account_prefix) do |format|
        format.text { render "layouts/email_templates/dm_cms_post_notify.text.erb" }
        format.html { render "layouts/email_templates/dm_cms_post_notify.html.erb" }
      end
    end
  end

end