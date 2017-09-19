# Lesson Page: Each lesson contains different pages of material - a video page,
# an explantation page, a quizz page.
#   Each page has a content type, such as a teaching (video/explanation) or quizz
#------------------------------------------------------------------------------
class LessonPage < ApplicationRecord
  
  self.table_name         = 'lms_lesson_pages'
  
  extend FriendlyId
  include DmCore::Concerns::FriendlyId
  friendly_id             :model_slug, use: :scoped, scope: [:account_id, :lesson]

  belongs_to              :lesson
  belongs_to              :item, polymorphic: true, dependent: :destroy

  acts_as_commentable
  
  include RankedModel
  ranks                   :row_order, with_same: :lesson_id
  default_scope           { where(account_id: Account.current.id).order(:row_order) }
  
  scope :published,       -> { where(published: true) }
  scope :next,            lambda {|row_order, lesson_id| where("row_order > ? AND lesson_id = ?", row_order, lesson_id) }
  scope :previous,        lambda {|row_order, lesson_id| where("row_order < ? AND lesson_id = ?", row_order, lesson_id) }

  delegate                :title, :menutitle, to: :item
  DmCore::Language.language_array.each do |lang|
    delegate                "title_#{lang}", "menutitle_#{lang}", to: :item
  end
  
  validates_uniqueness_of :slug, scope: :lesson_id
  validates_length_of     :slug, maximum: 255

  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def comments_allowed?
    true
  end
  
  # Find the next/previous objects, based on the row_order.
  # if the next/previous page is not there, then look in the
  # next/previous lesson
  #------------------------------------------------------------------------------
  def next(options = {})
    options = options.reverse_merge(published_only: true)
    page = LessonPage.next(self.row_order, self.lesson_id)
    page = (options[:published_only] ? page.published : page).try(:first)
    if page.nil?
      lesson = self.lesson.next(options)
      if !lesson.nil?
        page = (options[:published_only] ? lesson.lesson_pages.published : lesson.lesson_pages).try(:first)
      end
    end
    return page
  end

  def previous(options = {})
    options = options.reverse_merge(published_only: true)
    page = LessonPage.previous(self.row_order, self.lesson_id)
    page = (options[:published_only] ? page.published : page).try(:last)
    if page.nil?
      lesson = self.lesson.previous(options)
      if !lesson.nil?
        page = (options[:published_only] ? lesson.lesson_pages.published : lesson.lesson_pages).try(:last)
      end
    end
    return page
  end
end
