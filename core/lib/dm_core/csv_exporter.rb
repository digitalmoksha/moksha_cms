require 'csv'
require 'dm_core/scio_excel'

# require 'ruport'

# Implements CSV Export functionality
#------------------------------------------------------------------------------
module CsvExporter
  # include Ruport
  # include DmUtilities::RenderingHelper

  #------------------------------------------------------------------------------
  def data_export(column_definitions, data_array, options = {})
    case options[:format]
    when 'xls'
      excel_export(column_definitions, data_array, options)
    else
      csv_export(column_definitions, data_array, options)
    end
  end

  # Exports data to a CSV formatted file.
  # column_definitions: defines the name of the fields and how they are accessed.
  #   Array of items, where each item is an array of
  #     name used in CSV column
  #     name used to access the value in the data records
  #     width of field
  #     optional formatting instructions as a Hash
  #     ex)
  #        column_definitions = []
  #        column_definitions <<     ["Receipt Code",      "'R-' + item.receipt_code", 75]
  #        column_definitions <<     ["State",             "item.state.capitalize"]
  #        column_definitions <<     ['Process State',     'item.aasm_state', 100]
  #        column_definitions <<     ['Registered on',     'item.created_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
  #        column_definitions <<     ["Price",             "item.workshop_price.price.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
  #
  # data_array: an array of objects (link from a find)
  # :filename => 'file_name' name of file to save as.
  # :expressions => true : the data definintion can be a complex expression,
  #    so simply evaluate it directly. To access the current item, the expression
  #    should use 'item', as in 'item.name.blank? ? "n/a" : item.name'
  #------------------------------------------------------------------------------
  def csv_export(column_definitions, data_array, options = {})
    options.symbolize_keys
    output_array = []
    csv_string   = CSV.generate do |csv|
      column_definitions.each { |x| output_array << x[0] }
      csv << output_array

      data_array.each do |item|
        output_array.clear
        column_definitions.each do |x|
          data = get_data_value(item, x[1], options)
          # data = "\"#{data}\"" if data.include?(',') #--- add quotes if comma included
          output_array << data
        end
        csv << output_array
      end
    end

    return csv_string unless options[:filename]

    send_data csv_string, filename: to_csv_filename(options[:filename]), disposition: 'attachment', type: 'text/csv'
  end

  # Exports data to a CSV formatted file, using columns directly from a table
  # table_name: name of the table exporting. Column names are pulled from it.
  # data_array: an array of hashes (link from a find)
  #------------------------------------------------------------------------------
  def csv_export_rawtable(table_name, data_array, options = {})
    column_definitions = []
    eval("#{table_name}.content_columns").each do |column|
      column_definitions << [column.name, column.name]
    end
    csv_export(column_definitions, data_array, options)
  end

  # Exports data to an Excel formatted file.
  # column_definitions: defines the name of the fields and how they are accessed.
  #   Array of items, where each item is an array of
  #     name used in CSV column
  #     name used to access the value in the data records
  #     width of field
  #     optional formatting instructions as a Hash
  #     ex)
  #        column_definitions = []
  #        column_definitions <<     ["Receipt Code",      "'R-' + item.receipt_code", 75]
  #        column_definitions <<     ["State",             "item.state.capitalize"]
  #        column_definitions <<     ['Process State',     'item.aasm_state', 100]
  #        column_definitions <<     ['Registered on',     'item.created_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
  #        column_definitions <<     ["Price",             "item.workshop_price.price.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
  #
  # data_array: an array of objects (link from a find)
  # :filename => 'file_name' name of file to save as.
  # :expressions => true : the data definintion can be a complex expression,
  #    so simply evaluate it directly. To access the current item, the expression
  #    should use 'item', as in 'item.name.blank? ? "n/a" : item.name'
  #------------------------------------------------------------------------------
  def excel_export(column_definitions, data_array, options = {})
    options.symbolize_keys
    rows      = []
    columns   = []

    #--- create the workbook
    wb          = Scio::Excel::SimpleWorkbook.new(to_excel_filename(options[:filename] ? options[:filename] : 'Workbook'))
    stc         = wb.default_cell_style
    stc.borders = stc.borders & 0

    column_definitions.each do |x|
      style = x[3].nil? ? nil : Scio::Excel::SimpleStyle.new(x[3])
      c = Scio::Excel::Column.new(x[0], x[3].nil? ? {} : x[3])
      c.width = x[2] unless x[2].nil?
      c.cell_style = style
      columns << c
    end

    data_array.each do |item|
      data = {}
      column_definitions.each do |x|
        data[x[0]] = get_data_value(item, x[1], options)
      end
      rows << data
    end

    wb.columns  = columns
    wb.rows     = rows

    return wb.create unless options[:filename]

    send_data wb.create, filename: to_excel_filename(options[:filename]), disposition: 'attachment', type: 'application/excel'
  end

  #------------------------------------------------------------------------------
  # def ruport_export(column_definitions, data_array, options = {})
  #   options.symbolize_keys
  #   output_array = []
  #   column_array = []
  #
  #   column_definitions.each { |x| column_array << x[0] }
  #
  #   table = Table(column_array) do |t|
  #     data_array.each do |item|
  #       output_array.clear
  #       column_definitions.each do |x|
  #         value = get_data_value(item, x[1], options)
  #         output_array << convert_value(value, x[3])
  #       end
  #       t << output_array
  #     end
  #   end
  #   return table
  # end

  private

  #------------------------------------------------------------------------------
  def get_data_value(item, data_def, options)
    begin
      value = if item.is_a? Hash
                options[:expressions] ? eval('(' + data_def + ').to_s') : eval('item[' + data_def + '].to_s')
              else
                options[:expressions] ? eval('(' + data_def + ').to_s') : eval('item.' + data_def + '.to_s')
              end
    rescue StandardError
      # catch any nil references
      value = nil
    end

    value.nil? ? '' : value.gsub(/[\r\n]/, '') # strip off \r and \n
  end

  # Use the column_options to change data to a specific type
  #------------------------------------------------------------------------------
  def convert_value(value, column_options)
    if column_options
      case column_options[:type]
      when 'Number'
        return value.to_i
      end
    end

    value
  end

  #------------------------------------------------------------------------------
  def to_csv_filename(title)
    the_time    = Time.now
    file_prefix = "#{the_time.year}_#{the_time.mon}_#{the_time.day}_"
    filename    = (file_prefix + title.gsub(/[^\w\.\-]/, '_')).squeeze('_')
    filename + '.csv'
  end

  # Older Excel limited to 32 char filenames
  # -- removed filename length limit - put back if problems occur
  #------------------------------------------------------------------------------
  def to_excel_filename(title)
    the_time    = Time.now
    file_prefix = "#{the_time.year}_#{the_time.mon}_#{the_time.day}_"
    filename    = (file_prefix + title.gsub(/[^\w\.\-]/, '_')).squeeze('_')
    # --- removed filename length limit - put back if problems occur : (filename.length > 27 ? filename[0...27] : filename) + '.xls'
    filename + '.xls'
  end
end
