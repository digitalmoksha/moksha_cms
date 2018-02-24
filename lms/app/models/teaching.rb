#------------------------------------------------------------------------------
class Teaching < ApplicationRecord
  self.table_name = 'lms_teachings'

  # --- globalize
  translates              :title, :menutitle, :content, foreign_key: :teaching_id, fallbacks_for_empty_translations: true
  globalize_accessors     locales: I18n.available_locales

  has_one                 :lesson_page, as: :item
  delegate                :slug, :published, "published?", to: :lesson_page

  default_scope           { where(account_id: Account.current.id) }

  validates               :title, presence_default_locale: true
  validates               :content, liquid: { locales: true }, presence_default_locale: true

  I18n.available_locales.each do |locale|
    validates_length_of   :"title_#{locale}", maximum: 255
    validates_length_of   :"menutitle_#{locale}", maximum: 255
  end
end
