# Generic contact form class.  If changes are needed, then a new version should
# be created in the theme's models folder
#------------------------------------------------------------------------------
class ContactForm < ::MailForm::Base
  
  attribute :name,        :validate => true
  attribute :email,       :validate =>  /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :organization                    # Not validated
  attribute :subject,     :validate => true
  attribute :message,     :validate => true
  attribute :reason,      :validate => true
  attribute :nickname,    :captcha  => true
  
  # append    :remote_ip, :user_agent, :session   # append these values to the end of all emails

  #------------------------------------------------------------------------------
  def headers
    { subject:  "#{I18n.t('cms.contact_form.subject_prefix')}: #{reason}: #{subject}" , 
      to:       Account.current.preferred_support_email,
      from:     %("#{name}" <#{email}>),
      reply_to: %("#{name}" <#{email}>)
    }
  end
end