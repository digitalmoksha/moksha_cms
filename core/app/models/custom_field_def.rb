# Reference: "Handle Multiple Models in One Form" from "Advanced Rails Recipes"
# and http://railscasts.com/episodes/403-dynamic-forms
# and http://railscasts.com/episodes/196-nested-model-form-revised
# Note: tried to use coder: JSON for the store, but kept getting a 
# "A JSON text must at least contain two octets!" exception (from new fields)
# so store in yaml format instead
#------------------------------------------------------------------------------
class CustomFieldDef < ActiveRecord::Base
  self.table_name         = 'core_custom_field_defs'
                          
  belongs_to              :owner, polymorphic: true
  has_many                :custom_fields, dependent: :destroy
  store                   :properties, accessors: [:choice_list, :valid_until]
                          
  include RankedModel
  ranks                   :row_order, with_same: [:owner_id, :owner_type]
  default_scope           { where(account_id: Account.current.id) }

  translates              :label, :description, fallbacks_for_empty_translations: true
  globalize_accessors     locales: DmCore::Language.language_array

  validates_presence_of   :field_type
  validates_length_of     :field_type, maximum: 20

  FIELD_TYPES = [ ['Text Field',      'text_field'], 
                  ['Text Area',       'text_area'],
                  ['Number Field',    'number_field'],
                  ['Checkboxes',      'check_box_collection'], 
                  ['Radio Buttons',   'radio_buttons'], 
                  ['Drop Down Menu',  'select'], 
                  ['Divider',         'divider']
                  # ['Date/Time Selection', 'date_time'],
                  # ['Date Selection', 'date'],
                  # ['Country Selection', 'country'],
                ].freeze

  #------------------------------------------------------------------------------
  def divider?
    fieldtype == 'divider'
  end

  #------------------------------------------------------------------------------
  def choice_list_array
    choice_list.split(',').collect { |item| item.strip }
  end
  
  # Text to use for the column during export or in reports.  The label will
  # be used if the 'name' attribute is blank
  #------------------------------------------------------------------------------
  def column_name
    self.name.blank? ? self.label.to_s_default : self.name
  end

end

# # TODO Several problems need to be solved before migrating completely 
# #      to using these custom fields.  One is we need to be able to refill the fields
# #      with not only the orignal values, but any new values input.  If the form 
# #      is submitted and validation fails, those fields should be filled with the
# #      values again.  Maybe creating an actual @custom_fields array or something.
# #      Just not sure how to do it right now.
# #
# #------------------------------------------------------------------------------
#   # --- globalize
#   translates              :label, :leadin_text, fallbacks_for_empty_translations: true
#   globalize_accessors     locales: SupportedLanguages.language_array
# 
#   validates_presence_of   :fieldtype
#   validates_length_of     :fieldtype,   maximum: 20
#   validates_presence_of   :column_name
#   validates_length_of     :column_name, maximum: 50
#   #validates_length_of     :label, maximum: 255 - removed because it was somehow failing when you deleted all custom fields and then tried adding a new one
# 
#   
#   # custom field is visible if it's not disabled and it's still valid
#   #------------------------------------------------------------------------------
#   def visible?
#     !(disabled? || (!valid_until.nil? && valid_until < Time.now.to_date))
#   end
#   
#   #------------------------------------------------------------------------------
#   def create_copy(new_owner_id)
#     field_def           = CustomFieldDef.new(attributes)
#     field_def.owner_id  = new_owner_id
#     
#     SupportedLanguages.languages.each do |locale|
#       eval("field_def.label_#{locale[:lang]}       = label_#{locale[:lang]} unless label_#{locale[:lang]}.nil?")
#       eval("field_def.leadin_text_#{locale[:lang]} = leadin_text_#{locale[:lang]} unless leadin_text_#{locale[:lang]}.nil?")
#     end
#     field_def.save(validate: false)
#   end
# end
