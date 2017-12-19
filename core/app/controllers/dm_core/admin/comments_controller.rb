# Common controller for handling comments in the admin interface
# http://pathfindersoftware.com/2008/07/drying-up-rails-controllers-polymorphic-and-super-controllers/
#------------------------------------------------------------------------------
class DmCore::Admin::CommentsController < DmCore::Admin::AdminController
  include DmCore::PermittedParams

  before_action :find_commenter

  # Create a comment
  # :commenter_type => object name of commenting object
  # :commenter_id   => object id of commenting object
  # :name           => optional prefix of association to use (eg. 'private' for private_comments)
  # :comment[:body] => text of comment
  #------------------------------------------------------------------------------
  def create
    params[:name] ||= 'comments'
    raise "Invalid Parameter" unless params[:name].end_with?('comments')
    association     = params[:name].to_sym

    respond_to do |format|
      if @commenter.respond_to? association
        @comment = @commenter.send(association).create(comment_params.merge(user_id: current_user.id))
        format.html { redirect_back fallback_location: main_app.index_url }
        format.js
      else
        format.html { redirect_back fallback_location: main_app.index_url }
      end
    end
  end

  #------------------------------------------------------------------------------
  def edit
    respond_to do |format|
      format.html { redirect_back fallback_location: main_app.index_url }
      format.js
    end
  end

  #------------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @comment.update_attributes(comment_params)
        format.html { redirect_back fallback_location: main_app.index_url }
        format.js
      end
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @comment.destroy if can?(:manage, :all) #|| comment.user == current_user
    respond_to do |format|
      format.html { redirect_back fallback_location: main_app.index_url }
      format.js
    end
  end

private

  #------------------------------------------------------------------------------
  def find_commenter
    if params[:id]
      @comment    = Comment.find(params[:id])
      @commenter  = @comment.commentable
    else
      klass       = params[:commenter_type].classify.constantize
      @commenter  = klass.find(params[:commenter_id])
    end
  end
end
