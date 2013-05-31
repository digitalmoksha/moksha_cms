class DmForum::Admin::ForumsController < DmForum::Admin::ApplicationController

  before_filter   :category_lookup, :only =>    [:index, :new, :create]
  before_filter   :forum_lookup,    :except =>  [:index, :new, :create]
  #before_filter   :set_title
  
  # GET /admin/fms/forums
  #------------------------------------------------------------------------------
  def index
    if ForumSite.first
      @forums = @forum_category.forums.ordered
    else
      redirect_to admin_forum_site_path, notice: "Please configure the Forum system first"
    end
  end

  #------------------------------------------------------------------------------
  def show
    
  end
  
  # GET /admin/fms/forums/new
  #------------------------------------------------------------------------------
  def new
    @forum = @forum_category.forums.build
  end

  # GET /admin/fms/forums/1/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # POST /admin/fms/forums
  #------------------------------------------------------------------------------
  def create
    @forum = @forum_category.forums.new(params[:forum])
    @forum.forum_site = ForumSite.site
    
    if @forum.save
      redirect_to admin_forum_category_url(@forum_category), notice: 'Forum was successfully created.'
    else
      render action: :new
    end
  end

  # PUT /admin/fms/forums/1
  #------------------------------------------------------------------------------
  def update
    if @forum.update_attributes(params[:forum])
      redirect_to admin_forum_url(@forum), notice: 'Forum was successfully updated.'
    else
      render action: :edit
    end
  end

  # DELETE /admin/fms/forums/1
  #------------------------------------------------------------------------------
  def destroy
    @forum.destroy

    redirect_to admin_forum_category_url(@forum.forum_category)
  end
  
  #------------------------------------------------------------------------------
  def sort
    @forum.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    render nothing: true
  end
  
  #------------------------------------------------------------------------------
  def forum_users
    respond_to do |format|
      format.json { render json: ForumUserDatatable.new(view_context, @forum) }
    end
  end
  
  # Add user(s) to forum.
  # => user_id: add a single user
  # => workshop_id: add all attending users, ignore duplicates
  #------------------------------------------------------------------------------
  def forum_add_member
    if !params[:user_id].blank?
      user = User.find(params[:user_id])
      user.add_role(:member, @forum)
      redirect_to admin_forum_url(@forum), notice: "Forum access granted for #{user.full_name}"
    elsif !params[:workshop_id].blank?
      workshop  = Workshop.find(params[:workshop_id])
      added     = 0
      workshop.registrations.attending.each do |r|
        if r.user_profile.user && !r.user_profile.user.has_role?(:member, @forum)
          r.user_profile.user.add_role(:member, @forum)
          added += 1
        end
      end
      redirect_to admin_forum_url(@forum), notice: "Forum access granted for #{added} user(s)"
    else
      redirect_to admin_forum_url(@forum), alert: "Incorrect parameters supplied"
    end
  end
  
  #------------------------------------------------------------------------------
  def forum_delete_member
    user = User.find(params[:user_id])
    user.remove_role(:member, @forum)
    redirect_to admin_forum_url(@forum), notice: "Forum access removed for #{user.full_name}"
  end
  
private

  #------------------------------------------------------------------------------
  def category_lookup
    @forum_category = ForumCategory.find(params[:forum_category_id])
  end

  #------------------------------------------------------------------------------
  def forum_lookup
    @forum = Forum.find(params[:id])
    @forum_category = @forum.forum_category
  end

end
