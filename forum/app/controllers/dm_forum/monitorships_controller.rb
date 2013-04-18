class DmForum::MonitorshipsController < ApplicationController
  before_filter :authenticate_user!

  #cache_sweeper :monitorships_sweeper

  #------------------------------------------------------------------------------
  def create
    @monitorship  = Monitorship.find_or_initialize_by_user_id_and_forum_topic_id(current_user.id, params[:forum_topic_id])
    forum_topic   = ForumTopic.find(params[:forum_topic_id])
    @monitorship.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to forum_forum_topic_path(params[:forum_id], forum_topic) }
      format.js
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    Monitorship.where(:user_id => current_user.id, :forum_topic_id => params[:forum_topic_id]).update_all(:active => false)
    forum_topic = ForumTopic.find(params[:forum_topic_id])
    respond_to do |format| 
      format.html { redirect_to forum_forum_topic_path(params[:forum_id], forum_topic) }
      format.js
    end
  end
end
