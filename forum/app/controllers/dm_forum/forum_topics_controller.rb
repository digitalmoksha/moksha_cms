class DmForum::ForumTopicsController < DmForum::ApplicationController
  include DmForum::PermittedParams

  before_action :find_forum
  before_action :find_topic, :only => [:show, :edit, :update, :destroy]
  # before_action :admin_required, :only => [:edit, :update, :destroy]
  #

  layout    'forum_templates/forum_list'

  #------------------------------------------------------------------------------
  def index
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  do
        @forum_topics = find_forum.topics.paginate(:page => page_number)
        render :xml  => @forum_topics
      end
    end
  end

  #------------------------------------------------------------------------------
  def show
    (session[:forum_topics] ||= {})[@forum_topic.id] = Time.now.utc if user_signed_in?
    @forum_topic.hit! unless user_signed_in? && @forum_topic.user_id == current_user.id
    @forum_comments = @forum_topic.forum_comments.paginate :page => page_number
    @forum_comment  = ForumComment.new
    @following      = user_signed_in? && current_user.following.follows?(@forum_topic)
  end

  #------------------------------------------------------------------------------
  def new
    @forum_topic = @forum.forum_topics.new
  end

  #------------------------------------------------------------------------------
  def create
    params[:forum_topic].delete(:forum_id)
    @forum_topic = @forum.forum_topics.new(forum_topic_params)
    @forum_topic.user = current_user
    if @forum_topic.save
      current_user.following.follow(@forum_topic)
      redirect_to forum_forum_topic_path(@forum, @forum_topic), notice: 'Topic was successfully created.'
    else
      render :action => :new
    end
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def update
    #current_user.revise @topic, params[:topic]
    attributes = forum_topic_params
    @forum_topic.title = attributes[:title] if attributes.key?(:title)
    @forum_topic.sticky, @forum_topic.locked, @forum_topic.forum_id = attributes[:sticky], attributes[:locked], attributes[:forum_id] if can?(:moderate, @forum_topic.forum)
    @forum_topic.save
    if @forum_topic.errors.empty?
      flash[:notice] = 'Topic was successfully updated.'
      redirect_to(forum_forum_topic_path(Forum.find(@forum_topic.forum_id), @forum_topic))
    else
      render :action => "edit"
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @forum_topic.destroy if is_admin?
    redirect_to @forum
  end

  #------------------------------------------------------------------------------
  def toggle_follow
    @forum_topic  = @forum.forum_topics.find(params[:forum_topic_id])
    DmCore::ToggleFollowerService.new(current_user, @forum_topic).call
  end

  protected

  #------------------------------------------------------------------------------
  def find_forum
    @forum = Forum.find_by_slug!(params[:forum_id])
    authorize! :read, @forum
  end

  #------------------------------------------------------------------------------
  def find_topic
    @forum_topic = @forum.forum_topics.find_by_slug!(params[:id])
  end
end