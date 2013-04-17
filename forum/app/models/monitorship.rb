class Monitorship < ActiveRecord::Base

  self.table_name   = 'fms_monitorships'

  belongs_to        :user
  belongs_to        :forum_topic

  validates         :user_id, :forum_topic_id, :presence => true
  validate          :uniqueness_of_relationship
  before_create     :check_for_inactive

  attr_accessible   :user_id, :forum_topic_id, :active

protected

  #------------------------------------------------------------------------------
  def uniqueness_of_relationship
    if self.class.exists?(:user_id => user_id, :forum_topic_id => topic_id, :active => true)
      errors.add(:base, "Cannot add duplicate user/topic relation")
    end
  end

  #------------------------------------------------------------------------------
  def check_for_inactive
    monitorship = self.class.find_by_user_id_and_forum_topic_id_and_active(user_id, forum_topic_id, false)
    if monitorship
      monitorship.active = true
      monitorship.save
      false
    end
  end
end