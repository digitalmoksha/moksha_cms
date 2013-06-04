class PostNotifyMailer < DmCore::SiteMailer
  
  helper DmCore::LiquidHelper
    
  #------------------------------------------------------------------------------
  def post_notify(post, email)
    account                     = post.account
    @subject                    = "Blog: #{post.cms_blog.title} :: #{post.title}"
    @recipients                 = email
    @blog_title                 = post.cms_blog.title
    @post_title                 = post.title
    @post_summary               = post.display_summary
    @post_link                  = dm_cms.post_show_url(post.cms_blog.slug, post.slug, locale: I18n.locale)

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