class AvatarUploader < CarrierWave::Uploader::Base
  include DmCore::AccountHelper
  include CarrierWave::MiniMagick

  storage :file

  #------------------------------------------------------------------------------
  def store_dir
    Rails.root.join('public', 'site_assets', '_shared', 'avatars').to_s
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

  # Modern cameras often produce JPEGs that have a "I should be rotated 90deg to the left" flag.
  # Carrierwave ignores this setting, so fix it here
  # https://makandracards.com/makandra/12323-carrierwave-auto-rotate-tagged-jpegs
  #------------------------------------------------------------------------------
  def auto_orient
    manipulate!(&:auto_orient)
  end

  # Create different versions of your uploaded files:
  #------------------------------------------------------------------------------
  version :sq35 do
    process :auto_orient
    process resize_to_fill: [35, 35]
  end
  version :sq100 do
    process :auto_orient
    process resize_to_fill: [100, 100]
  end
  version :sq200 do
    process :auto_orient
    process resize_to_fill: [200, 200]
  end
  version :w100 do
    process :auto_orient
    process resize_to_width: [100]
  end
  version :w200 do
    process :auto_orient
    process resize_to_width: [200]
  end
  version :w300 do
    process :auto_orient
    process resize_to_width: [300]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #------------------------------------------------------------------------------
  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  #------------------------------------------------------------------------------
  def default_url(*args)
    "/site_assets/_shared/avatars/" + ["empty_avatar", version_name].compact.join('_') + '.png'
  end

  protected

  #------------------------------------------------------------------------------
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
  end
end
