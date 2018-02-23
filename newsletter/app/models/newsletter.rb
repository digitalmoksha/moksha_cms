#------------------------------------------------------------------------------
class Newsletter < ApplicationRecord
  self.table_name = 'email_newsletters'

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

  #------------------------------------------------------------------------------
  def map_error_to_msg(code)
  end

  # Find the newsletter associated with the token
  #------------------------------------------------------------------------------
  def self.find_newsletter(token, options = {})
    Newsletter.find_by_token(token)
  end

  #------------------------------------------------------------------------------
  def self.signup_information(token, options = {})
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