# For uploading files into the media library.  Creates versions based on
# settings in the Account.  Will also create retina versions automatically.
# Files are stored in `uploads` in the site specific `media` folder.  User can specify a single
# subfolder to store the file, giving a little extra flexibility.
# At the moment, files are in the public folders.  Future version may
# allow uploading protected files.
#
# make sure ghostscript is installed for PDF thumbnailing
# on macOS, `brew install ghostscript`
#------------------------------------------------------------------------------
class MediaUploader < CarrierWave::Uploader::Base
  include DmCore::AccountHelper
  include CarrierWave::MiniMagick

  # media files could be stored locally or on a cloud provider.
  # let the main app decide
  # storage :file

  # Everything gets stored in the `uploads/[site]/media` folder
  #------------------------------------------------------------------------------
  def store_dir
    partition_dir = model.folder
    "#{account_site_assets_media(false)}/#{partition_dir}"
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

  # Modern cameras often produce JPEGs that have a "I should be rotated 90° to the left" flag.
  # Carrierwave ignores this setting, so fix it here
  # https://makandracards.com/makandra/12323-carrierwave-auto-rotate-tagged-jpegs
  #------------------------------------------------------------------------------
  def auto_orient
    unless svg?(self)
      manipulate! do |img|
        img = img.auto_orient
      end
    end
  end

  # If a pdf, convert to jpg and size, maintain aspect ration and pad to square
  # If an image, resize it to a cropped square
  #------------------------------------------------------------------------------
  def thumb_image_pdf(width, height)
    if pdf?(self)
      self.convert(:jpg)
      self.resize_and_pad(width, height)
      self.file.content_type = 'image/jpeg'
    else
      self.resize_to_fill(width, height) unless svg?(self)
    end
  end

  # Convert to jpg if a pdf, then size to a specfic width
  #------------------------------------------------------------------------------
  def size_image_pdf(width)
    if pdf?(self)
      self.convert(:jpg, 0)
      self.file.content_type = 'image/jpeg'
    end
    self.resize_to_width(width) unless svg?(self)
  end

  # From: https://github.com/jhnvz/retina_rails
  # Process retina quality of the image. Works with ImageMagick and MiniMagick
  #   Params: [percentage (Int)] quality in percentage
  #------------------------------------------------------------------------------
  def retina_quality(percentage)
    unless svg?(self)
      manipulate! do |img|
        if defined?(Magick)
          img.write(current_path) { self.quality = percentage } unless img.quality == percentage
        elsif defined?(MiniMagick)
          img.quality(percentage.to_s)
        end
        img = yield(img) if block_given?
        img
      end
    end
  end

  # Create different versions of image files
  #   Retina naming: http://blog.remarkablelabs.com/2013/01/creating-retina-images-with-carrierwave
  #------------------------------------------------------------------------------
  version :retina_lg, if: :thumbnable_retina? do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_large_width * 2]
    process size_image_pdf: [900 * 2]
    process retina_quality: 60
    def full_filename(for_file = model.file.file)
      name = filename_retina(super)
      filename_pdf_to_jpg(name)
    end
  end
  version :lg, if: :thumbnable? do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_large_width]
    process size_image_pdf: [900]
    def full_filename (for_file = model.file.file)
      filename_pdf_to_jpg(super)
    end
  end

  #------------------------------------------------------------------------------
  version :retina_md, if: :thumbnable_retina?, from_version: :retina_lg do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_medium_width * 2]
    process size_image_pdf: [600 * 2]
    process retina_quality: 60
    def full_filename(for_file = model.file.file)
      name = filename_retina(super)
      filename_pdf_to_jpg(name)
    end
  end
  version :md, if: :thumbnable?, from_version: :lg do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_medium_width]
    process size_image_pdf: [600]
    def full_filename (for_file = model.file.file)
      filename_pdf_to_jpg(super)
    end
  end

  #------------------------------------------------------------------------------
  version :retina_sm, if: :thumbnable_retina?, from_version: :retina_md do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_small_width * 2]
    process size_image_pdf: [300 * 2]
    process retina_quality: 60
    def full_filename(for_file = model.file.file)
      name = filename_retina(super)
      filename_pdf_to_jpg(name)
    end
  end
  version :sm, if: :thumbnable?, from_version: :lg do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_small_width]
    process size_image_pdf: [300]
    def full_filename (for_file = model.file.file)
      filename_pdf_to_jpg(super)
    end
  end

  #------------------------------------------------------------------------------
  version :thumb, if: :thumbnable?, from_version: :md do
    process :auto_orient
    # process thumb_image_pdf: [Account.current.preferred_image_thumbnail_width, Account.current.preferred_image_thumbnail_width]
    process thumb_image_pdf: [200, 200]
    def full_filename (for_file = model.file.file)
      filename_pdf_to_jpg(super)
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  #------------------------------------------------------------------------------
  def extension_whitelist
    %w(jpg jpeg gif png svg mp3 mp4 m4v ogg webm pdf css js)
  end

  protected

  #------------------------------------------------------------------------------
  def thumbnable?(new_file)
    image?(new_file) || pdf?(new_file)
  end

  #------------------------------------------------------------------------------
  def thumbnable_retina?(new_file)
    model.generate_retina? ? thumbnable?(new_file) : false
  end

  #------------------------------------------------------------------------------
  def image?(new_file)
    model.new_record? ? new_file.content_type.start_with?('image') : model.image?
  end

  #------------------------------------------------------------------------------
  def pdf?(new_file)
    model.new_record? ? new_file.content_type.end_with?('pdf') : model.pdf?
  end

  #------------------------------------------------------------------------------
  def svg?(new_file)
    model.new_record? ? new_file.content_type.start_with?('image/svg') : model.image?
  end

  #------------------------------------------------------------------------------
  def filename_pdf_to_jpg(filename)
    pdf?(self) ? (filename.chomp(File.extname(filename)) + '.jpg') : filename
  end

  #------------------------------------------------------------------------------
  def filename_retina(filename)
    filename.gsub(/\.+[0-9a-zA-Z]{3,4}$/){ "@2x#{$&}" }.gsub('retina_', '')
  end
end
