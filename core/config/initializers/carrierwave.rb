#------------------------------------------------------------------------------
# Put the version name at the end of the file, instead of beginning
# https://github.com/carrierwaveuploader/carrierwave/wiki/How-To:-Move-version-name-to-end-of-filename,-instead-of-front
#------------------------------------------------------------------------------
module CarrierWave
  module Uploader
    module Versions
      def full_filename(for_file)
        parent_name = super(for_file)
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end

      def full_original_filename
        parent_name = super
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end
    end
  end
end
