# encoding: utf-8
#------------------------------------------------------------------------------
class AvatarUploader < CarrierWave::Uploader::Base
  include DmCore::AccountHelper

  # Include RMagick or MiniMagick support:
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  #------------------------------------------------------------------------------
  def store_dir
    "#{Rails.root}/public/site_assets/_shared/avatars"
  end

  #------------------------------------------------------------------------------
  def filename
     "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  # We basically want the width to be the max, allowing the height to grow
  #------------------------------------------------------------------------------
  def resize_to_width(width)
    manipulate! do |img|
      img.resize "#{width}>"
      img = yield(img) if block_given?
      img
    end
  end

  # Create different versions of your uploaded files:
  #------------------------------------------------------------------------------
  version :sq35 do
    process :resize_to_fill => [35, 35]
  end
  version :sq100 do
    process :resize_to_fill => [100, 100]
  end
  version :sq200 do
    process :resize_to_fill => [200, 200]
  end
  version :w100 do
    process :resize_to_width => [100]
  end
  version :w200 do
    process :resize_to_width => [200]
  end
  version :w300 do
    process :resize_to_width => [300]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #------------------------------------------------------------------------------
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  #------------------------------------------------------------------------------
  def default_url
    "/site_assets/_shared/avatars/" + ["empty_avatar", version_name].compact.join('_') + '.png'
  end

protected

  #------------------------------------------------------------------------------
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end

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
