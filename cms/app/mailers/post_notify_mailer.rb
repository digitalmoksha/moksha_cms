class PostNotifyMailer < DmCore::SiteMailer
  
  helper  DmCms::PostsHelper
  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper

  layout 'email_templates/dm_cms_email_layout'

  #------------------------------------------------------------------------------
  def post_notify(user, post)
    account                     = post.account
    @subject                    = "Blog: #{post.cms_blog.title} :: #{post.title}"
    @recipients                 = user.email
    @blog_title                 = post.cms_blog.title
    @post_title                 = post.title
    @post_link                  = dm_cms.post_show_url(post.cms_blog.slug, post.slug, locale: I18n.locale)
    @post                       = post
    @header_image               = post.cms_blog.image_email_header || post.cms_blog.image

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