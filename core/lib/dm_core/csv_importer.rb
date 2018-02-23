# Implements CSV Import functionality
#------------------------------------------------------------------------------
module CsvImporter
  require 'csv'

  # import data from CSV file and return an Array of Hashes
  #------------------------------------------------------------------------------
  def csv_import(the_file)
    import_list = []
    CSV.foreach(the_file, headers: true) do |row|
      import_list << row.to_hash
    end
    return import_list
  end
end
