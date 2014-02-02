class DmForum::ForumCommentsController < DmForum::ApplicationController
  before_filter :find_parents
  before_filter :find_post, :only => [:edit, :update, :destroy]

  # {todo} look into caching and sweepers - most of our stuff is not directly public
  #cache_sweeper :forum_comments_sweeper, :only => [:create, :update, :destroy]

  # /posts
  # /users/1/posts
  # /forums/1/posts
  # /forums/1/topics/1/posts
  #------------------------------------------------------------------------------
  def index
    @followed         = user_signed_in? && params[:followed]
    @q                = params[:q] ? params[:q].purify : nil
    @posts            = (@parent ? @parent.forum_comments : ForumSite.site.forum_comments).search(@q, :page => page_number)
    @followed_posts   = user_signed_in? ? (@parent ? @parent.forum_comments : ForumSite.site.forum_comments).search_followed(current_user.id, @q, :page => page_number) : nil
    @users            = @user ? {@user.id => @user} : User.index_from(@posts)
  end

  #------------------------------------------------------------------------------
  def show
    redirect_to forum_forum_topic_path(@forum, @forum_topic)
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    @forum_comment = ForumComment.create_comment(@forum_topic, params[:forum_comment][:body], current_user)    
    if @forum_comment.new_record?
      redirect_to forum_forum_topic_path(@forum, @forum_topic)
    else
      current_user.following.follow(@forum_topic)
      flash[:notice] = 'Comment successfully created.'
      redirect_to(forum_forum_topic_path(@forum, @forum_topic, {:anchor => dom_id(@forum_comment), :page => @forum_topic.last_page}))
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @forum_comment.update_attributes(params[:forum_comment])
      flash[:notice] = 'Post was successfully updated.'
      redirect_to(forum_forum_topic_path(@forum, @forum_topic, {:anchor => dom_id(@forum_comment), :page => @forum_topic.comment_page(@forum_comment)}))
    else
      render :action => :edit
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @forum_comment.destroy

    if @forum.forum_topics.exists?(@forum_topic)
      redirect_to forum_forum_topic_path(@forum, @forum_topic)
    else
      redirect_to @forum
    end
  end

protected

  #------------------------------------------------------------------------------
  def find_parents
    if params[:user_id]
      @parent = @user = User.find(params[:user_id])
    elsif params[:forum_id]
      @parent = @forum        = Forum.find_by_slug!(params[:forum_id])
      @parent = @forum_topic  = @forum.forum_topics.find_by_slug(params[:forum_topic_id]) if params[:forum_topic_id]
      authorize! :read, @forum
    end
  end

  #------------------------------------------------------------------------------
  def find_post
    forum_comment = @forum_topic.forum_comments.find(params[:id])
    if forum_comment.user == current_user || can?(:moderate, @forum)
      @forum_comment = forum_comment
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
