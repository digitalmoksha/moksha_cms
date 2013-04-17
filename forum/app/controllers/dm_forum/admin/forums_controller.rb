class DmForum::Admin::ForumsController < DmForum::Admin::ApplicationController

  before_filter   :forum_lookup, :except =>  [:index, :new, :create]
  #before_filter   :set_title
  
  # GET /admin/fms/forums
  #------------------------------------------------------------------------------
  def index
    if ForumSite.first
      @forums = Forum.all
    else
      redirect_to admin_forum_site_path, notice: "Please configure the Forum system first"
    end
  end

  # GET /admin/fms/forums/new
  #------------------------------------------------------------------------------
  def new
    @forum = Forum.new
  end

  # GET /admin/fms/forums/1/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # POST /admin/fms/forums
  #------------------------------------------------------------------------------
  def create
    @forum = ForumSite.site.forums.new(params[:forum])

    if @forum.save
      redirect_to admin_forums_url, notice: 'Forum was successfully created.'
    else
      render action: :new
    end
  end

  # PUT /admin/fms/forums/1
  #------------------------------------------------------------------------------
  def update
    if @forum.update_attributes(params[:forum])
      redirect_to admin_forums_url, notice: 'Forum was successfully updated.'
    else
      render action: :edit
    end
  end

  # DELETE /admin/fms/forums/1
  #------------------------------------------------------------------------------
  def destroy
    @forum.destroy

    redirect_to admin_forums_url
  end
  
  #------------------------------------------------------------------------------
  def sort
    @forum.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    render nothing: true
  end
  
private

  #------------------------------------------------------------------------------
  def forum_lookup
    @forum = Forum.find(params[:id])
  end

end
