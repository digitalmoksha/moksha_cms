class DmCms::Admin::MediaFilesController < DmCms::Admin::AdminController
  include DmCms::PermittedParams

  #------------------------------------------------------------------------------
  def index
    @tag_filter  = params[:filter] || 'all'
    @media_files = MediaFile.order('folder, media ASC')

    @media_files = case @tag_filter
    when 'all'
      @media_files
    when 'top'
      @media_files.where(folder: '')
    else
      @media_files.tagged_with(@tag_filter)
    end
    @media_files = @media_files.paginate :page => params[:page], :per_page => 40
  end

  #------------------------------------------------------------------------------
  def new
    @media_file = MediaFile.new
  end
  
  #------------------------------------------------------------------------------
  def edit
    @media_file = MediaFile.find(params[:id])
  end
  
  #------------------------------------------------------------------------------
  def create
    @media_file   = MediaFile.new(media_file_params)  # for collecting all error msgs
    if params[:media_list]
      params[:media_list].each do |file|
        media_file       = MediaFile.new(media_file_params)
        media_file.media = file
        media_file.user  = current_user
        if !media_file.save
          media_file.errors.each { |attribute, error| @media_file.errors.add(attribute, error) }
        end
      end
    else
      @media_file.errors[:base] << 'Please select files to upload'
    end
    if @media_file.errors.empty?
      redirect_to admin_media_files_url, notice: 'Media successfully uploaded'
    else
      render action: :new
    end
  end
  
  #------------------------------------------------------------------------------
  def update
    @media_file       = MediaFile.find(params[:id])
    @media_file.user  = current_user

    #--- must be set before attributes saved, otherwise retina versions not generated
    @media_file.generate_retina = params[:media_file][:generate_retina] unless params[:media_file][:generate_retina].nil?
    if @media_file.update_attributes(media_file_params)
      redirect_to admin_media_files_url, notice: 'Media successfully updated'
    else
      render action: :edit
    end
  end
  
  #------------------------------------------------------------------------------
  def destroy
    @media_file = MediaFile.find(params[:id])
    @media_file.destroy
    redirect_to admin_media_files_url
  end
  
private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
  end

end
