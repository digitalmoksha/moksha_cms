# Common controller for handling comments in the admin interface
# http://pathfindersoftware.com/2008/07/drying-up-rails-controllers-polymorphic-and-super-controllers/
#------------------------------------------------------------------------------
class DmCore::Admin::CommentsController < DmCore::Admin::AdminController
  include DmCore::PermittedParams

  before_filter :find_commenter, except: [:destroy]

  # Create a comment
  # :commenter_type => object name of commenting object
  # :commenter_id   => object id of commenting object
  # :name           => optional prefix of association to use (eg. 'private' for private_comments)
  # :comment[:body] => text of comment
  #------------------------------------------------------------------------------
  def create
    association = params[:name].blank? ? :comments : "#{params[:name]}_comments".to_sym
    if @commenter.respond_to? association
      @comment = @commenter.send(association).create(comment_params.merge(user_id: current_user.id))
    end
    
    respond_to do |format|
      # format.html {redirect_to :controller => @commenter.class.to_s.pluralize.downcase, :action => :show, :id => @commenter.id}
      format.html { redirect_to :back }
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy if can?(:manage, :all) #|| comment.user == current_user
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

private

  #------------------------------------------------------------------------------
  def find_commenter
    klass       = params[:commenter_type].classify.constantize
    @commenter  = klass.find(params[:commenter_id])
  end
end
