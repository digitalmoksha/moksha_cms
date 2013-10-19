#------------------------------------------------------------------------------
class Newsletter < ActiveRecord::Base

  self.table_name         = 'email_newsletters'
  attr_accessible         :token, :name, :mc_id, :mc_web_id, :subscribed_count, :unsubscribed_count, 
                          :cleaned_count, :created_at, :deleted

  # [todo] has_many                :newsletter_subscribers, :dependent => :destroy

  validates_uniqueness_of :token
  
  
  default_scope           { where(account_id: Account.current.id) }
  before_create           :generate_token

  #------------------------------------------------------------------------------
  def subscribe(user_or_email, options = {FNAME: '', LNAME: ''})
  end
  
  #------------------------------------------------------------------------------
  def update_list_stats
  end
  
  # Find the newsletter associated with the token
  #------------------------------------------------------------------------------
  def self.find_newsletter(token, options = {})
    Newsletter.find_by_token(token)
  end
  
protected

  #------------------------------------------------------------------------------
  def generate_token
    self.token = loop do
      random_token = SecureRandom.hex(10)
      break random_token unless Newsletter.where(token: random_token).exists?
    end
  end

end