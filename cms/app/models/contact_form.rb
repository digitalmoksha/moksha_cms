# Generic contact form class.  If changes are needed, then a new version should
# be created in the theme's models folder
#------------------------------------------------------------------------------
class ContactForm < ::MailForm::Base
  
  attribute :name,        :validate => true
  attribute :email,       :validate =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  attribute :organization                    # Not validated
  attribute :subject,     :validate => true
  attribute :message,     :validate => true
  attribute :reason,      :validate => true
  attribute :nickname,    :captcha  => true
  
  append    :remote_ip, :user_agent, :session   # append these values to the end of all emails

  #------------------------------------------------------------------------------
  def headers
    { :subject => "#{reason}: #{subject}" , 
      :to => Account.current.preferred_support_email,
      :from => %("#{name}" <#{email}>)
    }
  end
end