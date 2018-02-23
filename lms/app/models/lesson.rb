# Lesson: Different lessons of a course - vowels, consonants, etc
#   Holds multiple lesson pages
#------------------------------------------------------------------------------
class Lesson < ApplicationRecord
  self.table_name = 'lms_lessons'

  # --- globalize
  translates              :title, :menutitle, :description, foreign_key: :lesson_id, fallbacks_for_empty_translations: true
  globalize_accessors     locales: I18n.available_locales

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId
  friendly_id             :model_slug, use: :scoped, scope: [:account_id, :course] # re-define so is scoped to the course as well

  belongs_to              :course
  has_many                :lesson_pages, dependent: :destroy

  include RankedModel
  ranks                   :row_order, with_same: :course_id
  default_scope           { where(account_id: Account.current.id).order(:row_order) }

  scope :published,       -> { where(published: true) }
  scope :next,            lambda {|row_order, course_id| where("row_order > ? AND course_id = ?", row_order, course_id) }
  scope :previous,        lambda {|row_order, course_id| where("row_order < ? AND course_id = ?", row_order, course_id) }

  # --- allow menutitle to be blank - it won't appear in navigation
  validates               :title, presence_default_locale: true
  validates_uniqueness_of :slug, scope: :course_id
  validates_length_of     :slug, maximum: 255
  I18n.available_locales.each do |locale|
    validates_length_of   :"title_#{locale}", maximum: 255
    validates_length_of   :"menutitle_#{locale}", maximum: 255
  end

  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  # Find the next/previous objects, based on the row_order
  #------------------------------------------------------------------------------
  def next(options = {published_only: true})
    lessons = Lesson.next(self.row_order, self.course_id)
    (options[:published_only] ? lessons.published : lessons).first
  end

  def previous(options = {published_only: true})
    lessons = Lesson.previous(self.row_order, self.course_id)
    (options[:published_only] ? lessons.published : lessons).last
  end
end
