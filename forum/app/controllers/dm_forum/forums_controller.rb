class DmForum::ForumsController < DmForum::ApplicationController
  include ApplicationHelper  

  #--- these are needed to support rendering layouts built for the CMS
  helper DmCms::RenderHelper
  helper DmCms::LiquidHelper
  helper DmCms::PagesHelper
  include DmCore::RenderHelper
  
  before_filter   :forum_lookup, :except =>  [:list]

  layout    'forum_templates/forum_list', :only => [:list, :show]
  
  # GET /forum
  #------------------------------------------------------------------------------
  def list
    @forums = Forum.available_forums(current_user)
  end

  # GET /forum/:slug
  #------------------------------------------------------------------------------
  def show
    (session[:forums]       ||= {})[@forum.id] = Time.now.utc
    (session[:forums_page]  ||= Hash.new(1))[@forum.id] = page_number if page_number > 1
    @monitored                = user_signed_in? && params[:monitored]
    @forum_topics           ||= @forum.forum_topics.paginate :page => page_number
    @monitored_topics       ||= user_signed_in? ? 
        (@forum.monitored_topics(current_user).paginate :page => page_number) :
        nil
  end

protected

  #------------------------------------------------------------------------------
  def forum_lookup
    @forum = Forum.find_by_slug!(params[:id])
    authorize! :read, @forum
  end

end
