#------------------------------------------------------------------------------
class MediaFile < ApplicationRecord
  self.table_name = 'cms_media_files'

  translates              :title, :description, fallbacks_for_empty_translations: true
  globalize_accessors     locales: I18n.available_locales
  acts_as_taggable

  belongs_to              :user
  default_scope           { where(account_id: Account.current.id) }
  validate                :validate_name_is_unique

  #--- Using Carrierwave
  mount_uploader          :media, MediaUploader
  before_save             :prepare_attributes

  #------------------------------------------------------------------------------
  def image?
    media_content_type.start_with? 'image'
  end

  #------------------------------------------------------------------------------
  def pdf?
    media_content_type.end_with? 'pdf'
  end

  #------------------------------------------------------------------------------
  def short_location(version = nil)
    filename = version ? media.versions[version].file.filename : media.file.filename
    folder.blank? ? filename : "#{folder}/#{filename}"
  end

  # return a list of tags for all media objects
  #------------------------------------------------------------------------------
  def self.tag_list_all
    MediaFile.tag_counts_on(:tags).map(&:name).sort
  end

  # Given a name in the form 'folder/filename.ext', grab the url with the correct version
  # Use 'version: :original' to allow the original version to be pulled
  #------------------------------------------------------------------------------
  def self.url_by_name(name, options = { version: :original })
    if name && (asset = MediaFile.find_by_name(name))
      options[:version] == :original ? asset.media.url : asset.media.url(options[:version])
    end
  end

  # Given a name in the form 'folder/filename.ext', check if the version exists.
  # Use 'version: :original' to allow the original version to be pulled
  #------------------------------------------------------------------------------
  def self.version_exists?(name, options = { version: :original })
    asset = MediaFile.find_by_name(name)
    if asset
      options[:version] == :original ? true : asset.media.version_exists?(options[:version])
    else
      false
    end
  end

  # Given a name in the form 'folder/filename.ext', return the correct media file
  #------------------------------------------------------------------------------
  def self.find_by_name(name)
    components  = name.split('/')
    filename    = components[-1]
    folder      = components[-2] || ''

    MediaFile.where(folder: folder, media: filename).first
  end

  private

  #------------------------------------------------------------------------------
  def validate_name_is_unique
    if new_record?
      if media.file.nil?
        errors.add :media, "please select a file to upload"
      elsif MediaFile.where(media: media.file.original_filename, folder: folder, account_id: account_id).count > 0
        errors.add :media, "'#{short_location}' already exists"
      end
    end
  end

  # Save the media metadata, and add the 'folder' as a tag
  #------------------------------------------------------------------------------
  def prepare_attributes
    if media.present? && will_save_change_to_media?
      self.media_content_type = media.file.content_type
      self.media_file_size    = media.file.size
    end

    if new_record?
      self.folder = folder.sanitize_filename
      tag_list.add(folder)
      tag_list.add(media.file.extension)
    end
  end
end
