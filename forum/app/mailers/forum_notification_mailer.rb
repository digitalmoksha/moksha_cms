class ForumNotificationMailer < DmCore::SiteMailer
  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'DmForum::Engine.routes'

  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper

  #------------------------------------------------------------------------------
  def follower_notification(user, topic, comment_list)
    account         = topic.account
    Account.current = account # needed so this can run in a background job
    locale          = account.verify_locale(user.locale)
    I18n.with_locale(locale) do
      @subject        = "Comments: #{topic.title}"
      @recipients     = user.email
      @topic          = topic
      @comment_list   = comment_list
      @topic_link     = url_helpers.forum_forum_topic_url(topic.forum.slug, topic.slug, locale: I18n.locale, host: account.url_host)
      @forum_link     = url_helpers.forum_show_url(topic.forum.slug, locale: I18n.locale, host: account.url_host)

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
end