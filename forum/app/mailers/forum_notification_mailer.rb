class ForumNotificationMailer < DmCore::SiteMailer
  
  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper

  #------------------------------------------------------------------------------
  def follower_notification(user, topic, comment_list)
    account         = topic.account
    @subject        = "Commets: #{topic.title}"
    @recipients     = user.email
    @topic          = topic
    @comment_list   = comment_list
    @topic_link     = dm_forum.forum_forum_topic_url(topic.forum.slug, topic.slug, locale: I18n.locale)
    @forum_link     = dm_forum.forum_show_url(topic.forum.slug, locale: I18n.locale)
    
    theme(account.account_prefix)
    headers = { "Return-Path" => account.preferred_smtp_from_email }
    mail( from: account.preferred_smtp_from_email,
          reply_to: account.preferred_smtp_from_email,
          to: @recipients, subject: @subject) do |format|
      format.text { render "layouts/email_templates/forum_notification.text.erb" }
      format.html { render "layouts/email_templates/forum_notification.html.erb" }
    end
  end

end