# TODO The one problem I have with this is that when a field is empty, we still
#      save the record to the database.  The difficulty is that when the
#      form is displayed, you need to have all the records there, ones that
#      were saved and empty ones for those not saved, all in the proper order.
#      This presents a challenge I'm not willing to tackle at this moment.
#      But it should be done so that the database isn't cluttered with needless
#      records.
#
# Note: We serialize the data.  This makes it easy to store checkbox arrays, dates,
# etc, without having to worry about munging the data first.
#------------------------------------------------------------------------------
class CustomField < ApplicationRecord
  self.table_name = 'core_custom_fields'
  serialize                     :field_data

  # acts_as_reportable

  belongs_to                    :custom_field_def
  belongs_to                    :owner, polymorphic: true

  default_scope                 { where(account_id: Account.current.id) }

  # before_save                   :prepare_data

  delegate :field_type,         to: :custom_field_def
  delegate :name,               to: :custom_field_def
  delegate :label,              to: :custom_field_def
  delegate :description,        to: :custom_field_def
  delegate :required?,          to: :custom_field_def
  delegate :choice_list_array,  to: :custom_field_def

  # delegate :controldef,       to: :custom_field_def
  # delegate :leadin_text,      to: :custom_field_def
  # delegate :visible?,         to: :custom_field_def
  # delegate :divider?,         to: :custom_field_def
  # delegate :position,         to: :custom_field_def
  # delegate :show_in_list?,    to: :custom_field_def

  validates_presence_of         :field_data, if: Proc.new { |field| field.required? }
  validates_numericality_of     :field_data, if: Proc.new { |field| field.field_type == 'number_field' && !field.field_data.blank? }
  validates_length_of           :field_data, maximum: 4096, if: Proc.new { |field| !field.field_data.blank? }
  validate                      :checkbox_required, if: Proc.new { |field| field.field_type == 'check_box_collection' && field.required? }

  #------------------------------------------------------------------------------
  def initialize(*options, &block)
    super(*options, &block)
    # prepare_data
  end

  # Returns a munged value depending on the field type.  Used when data is exported.
  #------------------------------------------------------------------------------
  def value
    #--- if field is a country field, convert the country_id into real name
    if custom_field_def.field_type == 'country'
      Country.find(self.field_data.to_i).english_name
    elsif self.field_data.is_a? Array
      # make into a comma delimited string.  remove any blank/nil entries
      self.field_data.reject(&:blank?).join(', ')
    else
      self.field_data
    end
  end

  #------------------------------------------------------------------------------
  def checkbox_required
    errors.add(:field_data, :blank) if self.value.blank?
  end

  # # Munge the data so that it's stored correctly
  # #------------------------------------------------------------------------------
  # def prepare_data
  #   #--- an array of values is stores as a comma delimited string
  #   self.field_data = self.field_data.join(', ') if self.field_data.class == Array
  #
  #   # #--- if field is a date/time field, convert the date into database format
  #   # unless custom_field_def_id.nil?
  #   #   field_def = CustomFieldDef.find(custom_field_def_id)
  #   #   if field_def and !self.data.blank?
  #   #     if field_def.fieldtype == 'date_time' or field_def.fieldtype == 'date'
  #   #       self.data = Time.parse(self.data).to_s(:db)
  #   #     elsif field_def.fieldtype == 'number_field'
  #   #       p = NumberParser.new
  #   #       self.data = p.extract(self.data.to_s)[0]
  #   #     end
  #   #   end
  #   # end
  # end
  #
  # # Treat data as comma delimited, return it as an array of values
  # #------------------------------------------------------------------------------
  # def field_data_array
  #   self.field_data.nil? ? [] : self.field_data.split(',').collect { |item| item.strip }
  # end
  #
  # #------------------------------------------------------------------------------
  # def human_attribute_name(key)
  #   label.blank? ? 'Field' : "'#{nls(label, namespace: 'site_custom_field')}'"
  # end
end
