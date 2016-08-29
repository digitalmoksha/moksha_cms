class DmForum::ForumsController < DmForum::ApplicationController
  include ApplicationHelper  

  #--- these are needed to support rendering layouts built for the CMS
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  helper DmCms::PagesHelper
  include DmCore::RenderHelper
  
  before_filter   :forum_lookup, :except =>  [:list, :categories]

  layout    'forum_templates/forum_list', :only => [:list, :show, :categories]
  
  #------------------------------------------------------------------------------
  def categories
    @forum_categories = ForumCategory.ordered
  end
  
  # GET /forum
  #------------------------------------------------------------------------------
  def list
    @forums = Forum.available_to_user(current_user)
  end

  # GET /forum/:slug
  #------------------------------------------------------------------------------
  def show
    (session[:forums]       ||= {})[@forum.id] = Time.now.utc
    (session[:forums_page]  ||= Hash.new(1))[@forum.id] = page_number if page_number > 1
    @followed                 = user_signed_in? && params[:followed]
    @forum_topics           ||= @forum.forum_topics.paginate :page => page_number
    @followed_topics        ||= user_signed_in? ? 
        (@forum.followed_topics(current_user).paginate :page => page_number) :
        nil
  end

protected

  #------------------------------------------------------------------------------
  def forum_lookup
    @forum = Forum.find_by_slug!(params[:id])
    authorize! :read, @forum
  end

end
