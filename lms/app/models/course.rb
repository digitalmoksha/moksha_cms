# Course: container for a complete course - alaphabet, grammar level 1, etc.
#         Holds multiple lessons
#
# Note: use 'set_table' because 'table_name_prefix' will cause translation table
#       to have incorrect name
#------------------------------------------------------------------------------
class Course < ApplicationRecord
  include DmCore::Concerns::PublicPrivate

  self.table_name         = 'lms_courses'

  # globalize
  translates              :title, :menutitle, :description, foreign_key: :course_id, fallbacks_for_empty_translations: true
  globalize_accessors     locales: I18n.available_locales

  # FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  resourcify

  include RankedModel
  ranks                   :row_order, with_same: :account_id
  default_scope           { where(account_id: Account.current.id).order(:row_order) }

  scope                   :published, -> { where(published: true) }

  has_many                :lessons, dependent: :destroy
  belongs_to              :account
  belongs_to              :owner, polymorphic: true

  # --- allow menutitle to be blank - it won't appear in navigation
  validates_uniqueness_of :slug, scope: :account_id
  validates_length_of     :slug, maximum: 255
  validates               :title, presence_default_locale: true
  I18n.available_locales.each do |locale|
    validates_length_of   :"title_#{locale}", maximum: 255
    validates_length_of   :"menutitle_#{locale}", maximum: 255
  end

  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end
end

