class DmForum::Admin::ForumCategoriesController < DmForum::Admin::AdminController
  include DmForum::PermittedParams

  before_action   :check_forum_site,  only:   [:index]
  before_action   :category_lookup,   except: [:index, :new, :create]
  
  # GET /admin/forum_categories
  #------------------------------------------------------------------------------
  def index
    @forum_categories = ForumCategory.ordered
  end

  # GET /admin/forum_categories/1
  #------------------------------------------------------------------------------
  def show
  end

  # GET /admin/forum_categories/new
  #------------------------------------------------------------------------------
  def new
    @forum_category = ForumCategory.new
  end

  # GET /admin/forum_categories/1/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # POST /admin/forum_categories
  #------------------------------------------------------------------------------
  def create
    @forum_category = ForumCategory.new(forum_category_params)

    if @forum_category.save
      redirect_to admin_forum_category_url(@forum_category), notice: 'Forum Category was successfully created.'
    else
      render action: :new
    end
  end

  # PUT /admin/forum_categories/1
  #------------------------------------------------------------------------------
  def update
    if @forum_category.update_attributes(forum_category_params)
      redirect_to admin_forum_category_url(@forum_category), notice: 'Forum Category was successfully updated.'
    else
      render action: :edit
    end
  end

  # DELETE /admin/forum_categories/1
  #------------------------------------------------------------------------------
  def destroy
    @forum_category.destroy

    redirect_to admin_forum_categories_url
  end
  
  #------------------------------------------------------------------------------
  def sort
    @forum_category.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    head :ok
  end
  
private

  # make sure a ForumSite singleton is created
  #------------------------------------------------------------------------------
  def check_forum_site
    ForumSite.create(enabled: true) unless ForumSite.site
  end
  
  #------------------------------------------------------------------------------
  def category_lookup
    @forum_category = ForumCategory.find(params[:id])
  end

end
