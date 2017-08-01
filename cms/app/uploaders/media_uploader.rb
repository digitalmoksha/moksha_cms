# For uploading files into the media library.  Creates versions based on
# settings in the Account.  Will also create retina versions automatically.
# Files are stored in the theme's 'media' folder.  User can specify a single
# subfolder to store the file, giving a little extra flexibility.
# At the moment, files are in the public folders.  Future version will
# allow uploading protected files.
#
# make sure ghostscript is installed for PDF thumbnailing
# on OSX, `brew install ghostscript`
#------------------------------------------------------------------------------
class MediaUploader < CarrierWave::Uploader::Base
  include DmCore::AccountHelper

  # Include RMagick or MiniMagick support:
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :aws

  # Everything gets stored in the 'media' folder
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
    manipulate! do |img|
      img = img.auto_orient
    end
  end

  # If a pdf, convert to jpg and size, maintain aspect ration and pad to square
  # If an image, resize it to a cropped square
  #------------------------------------------------------------------------------
  def thumb_image_pdf(width, height)
    if pdf?(self)
      self.convert(:jpg)
      self.resize_and_pad(width, height)
    else
      self.resize_to_fill(width, height)
    end
  end
  
  # Convert to png if a pdf, then size to a specfic width
  #------------------------------------------------------------------------------
  def size_image_pdf(width)
    self.convert(:jpg, 0) if pdf?(self)
    self.resize_to_width(width)
  end
  
  # From: https://github.com/jhnvz/retina_rails
  # Process retina quality of the image.
  # Works with ImageMagick and MiniMagick
  # === Parameters
  #
  # [percentage (Int)] quality in percentage
  #
  def retina_quality(percentage)
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

  # Create different versions of image files
  #   Retina naming: http://blog.remarkablelabs.com/2013/01/creating-retina-images-with-carrierwave
  #------------------------------------------------------------------------------
  version :retina_lg, :if => :thumbnable_retina? do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_large_width * 2]
    process :size_image_pdf => [900 * 2]
    process :retina_quality => 60
    def full_filename(for_file = model.media.file)
      name = super.tap {|file_name| file_name.gsub!(/\.+[0-9a-zA-Z]{3,4}$/){ "@2x#{$&}" }.gsub!('retina_', '') }
      pdf?(self) ? (name.chomp(File.extname(name)) + '.jpg') : name
    end
  end
  version :lg, :if => :thumbnable? do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_large_width]
    process :size_image_pdf => [900]
    def full_filename (for_file = model.file.file)
      pdf?(self) ? (super.chomp(File.extname(super)) + '.jpg') : super
    end
  end

  version :retina_md, :if => :thumbnable_retina?, :from_version => :retina_lg do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_medium_width * 2]
    process :size_image_pdf => [600 * 2]
    process :retina_quality => 60
    def full_filename(for_file = model.media.file)
      name = super.tap {|file_name| file_name.gsub!(/\.+[0-9a-zA-Z]{3,4}$/){ "@2x#{$&}" }.gsub!('retina_', '') }
      pdf?(self) ? (name.chomp(File.extname(name)) + '.jpg') : name
    end
  end
  version :md, :if => :thumbnable?, :from_version => :lg do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_medium_width]
    process :size_image_pdf => [600]
    def full_filename (for_file = model.file.file)
      pdf?(self) ? (super.chomp(File.extname(super)) + '.jpg') : super
    end
  end

  version :retina_sm, :if => :thumbnable_retina?, :from_version => :retina_md do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_small_width * 2]
    process :size_image_pdf => [300 * 2]
    process :retina_quality => 60
    def full_filename(for_file = model.media.file)
      name = super.tap {|file_name| file_name.gsub!(/\.+[0-9a-zA-Z]{3,4}$/){ "@2x#{$&}" }.gsub!('retina_', '') }
      pdf?(self) ? (name.chomp(File.extname(name)) + '.jpg') : name
    end
  end
  version :sm, :if => :thumbnable?, :from_version => :md do
    process :auto_orient
    # process :size_image_pdf => [Account.current.preferred_image_small_width]
    process :size_image_pdf => [300]
    def full_filename (for_file = model.file.file)
      pdf?(self) ? (super.chomp(File.extname(super)) + '.jpg') : super
    end
  end

  version :thumb, :if => :thumbnable?, :from_version => :md do
    process :auto_orient
    # process thumb_image_pdf: [Account.current.preferred_image_thumbnail_width, Account.current.preferred_image_thumbnail_width]
    process thumb_image_pdf: [200, 200]
    def full_filename (for_file = model.file.file)
      pdf?(self) ? (super.chomp(File.extname(super)) + '.jpg') : super
    end
  end


  # Add a white list of extensions which are allowed to be uploaded.
  #------------------------------------------------------------------------------
  def extension_whitelist
    %w(jpg jpeg gif png mp3 mp4 m4v ogg webm pdf css js)
  end

protected

  #------------------------------------------------------------------------------
  def thumbnable?(new_file)
    image?(new_file) || pdf?(new_file)
  end

  #------------------------------------------------------------------------------
  def thumbnable_retina?(new_file)
    model.generate_retina? ? (image?(new_file) || pdf?(new_file)) : false
  end

  #------------------------------------------------------------------------------
  def image?(new_file)
    if new_file.content_type
      new_file.content_type.start_with? 'image'
    else
      new_file.model.image?
    end
  end

  #------------------------------------------------------------------------------
  def pdf?(new_file)
    if new_file.content_type
      new_file.content_type.end_with? 'pdf'
    else
      new_file.model.pdf?
    end
  end
  
end
