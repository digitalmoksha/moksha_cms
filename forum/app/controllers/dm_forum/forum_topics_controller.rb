class DmForum::ForumTopicsController < DmForum::ApplicationController

  before_filter :find_forum
  before_filter :find_topic, :only => [:show, :edit, :update, :destroy]
  # before_filter :admin_required, :only => [:edit, :update, :destroy]
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
  def edit
  end
  
  #------------------------------------------------------------------------------
  def show
    (session[:forum_topics] ||= {})[@forum_topic.id] = Time.now.utc if user_signed_in?
    @forum_topic.hit! unless user_signed_in? && @forum_topic.user_id == current_user.id
    @forum_comments = @forum_topic.forum_comments.paginate :page => page_number
    @forum_comment  = ForumComment.new
  end
  
  #------------------------------------------------------------------------------
  def new
    @forum_topic = @forum.forum_topics.new
  end
  
  #------------------------------------------------------------------------------
  def create
    params[:forum_topic].delete(:forum_id)
    @forum_topic = @forum.forum_topics.new(params[:forum_topic])
    @forum_topic.user = current_user
    if @forum_topic.save
      redirect_to forum_forum_topic_path(@forum, @forum_topic), notice: 'Topic was successfully created.'
    else
      render :action => :new
    end
  end
  
  # def update
  #   current_user.revise @topic, params[:topic]
  #   respond_to do |format|
  #     if @topic.errors.empty?
  #       flash[:notice] = 'Topic was successfully updated.'
  #       format.html { redirect_to(forum_topic_path(Forum.find(@topic.forum_id), @topic)) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml  => @topic.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # def destroy
  #   @topic.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(@forum) }
  #     format.xml  { head :ok }
  #   end
  # end
  
protected
  
  #------------------------------------------------------------------------------
  def find_forum
    @forum = Forum.find_by_slug!(params[:forum_id])
    raise ActiveRecord::RecordNotFound unless @forum.published? or current_user.is_admin?
  end
  
  #------------------------------------------------------------------------------
  def find_topic
    @forum_topic = @forum.forum_topics.find_by_slug!(params[:id])
  end


end