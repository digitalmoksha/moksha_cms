module DmForum
  module ForumHelper
    #------------------------------------------------------------------------------
    def topic_title_link(topic, options)
      if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
        "<span class='flag'>#{$1}</span>" +
          link_to($2.strip, forum_forum_topic_path(@forum, topic), options)
      else
        link_to(topic.title, forum_forum_topic_path(@forum, topic), options)
      end
    end

    #------------------------------------------------------------------------------
    def modify_history(function, name, path, params_hash = nil)
      state = "null"
      query_string = "?"
      if params_hash
        state = params_hash.to_json
        params_hash.each { |k, v| query_string << "#{k}=#{v}&" }
      end
      query_string = query_string.chop
      %{history.#{function}(#{state}, '#{j(name)}', '#{j(path + query_string)}');}.html_safe
    end

    #------------------------------------------------------------------------------
    def edited_on_tag(post)
      if (post.updated_at - post.created_at > 5.minutes)
        %{<span class='date'>#{I18n.t 'fms.post_edited', :when => time_ago_in_words(post.updated_at)}</span>}.html_safe
      end
    end

    # used to know if a topic has changed since we read it last
    #------------------------------------------------------------------------------
    def recent_topic_activity(topic)
      return false unless user_signed_in?

      return topic.last_updated_at > ((session[:forum_topics] ||= {})[topic.id] || last_active)
    end

    # used to know if a forum has changed since we read it last
    #------------------------------------------------------------------------------
    def recent_forum_activity(forum)
      return false unless user_signed_in? && forum.recent_topic

      return forum.recent_topic.last_updated_at > ((session[:forums] ||= {})[forum.id] || last_active)
    end

    #------------------------------------------------------------------------------
    def last_active
      session[:last_active] ||= Time.now.utc
    end

    # Ripe for optimization
    #------------------------------------------------------------------------------
    def voice_count
      pluralize ForumSite.site.forum_topics.to_a.sum { |t| t.voice_count }, 'voice'
    end

    #------------------------------------------------------------------------------
    def feed_icon_tag(title, url)
      # (@feed_icons ||= []) << { :url => url, :title => title }
      # link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
    end

    #------------------------------------------------------------------------------
    def forum_crumbs(forum = nil)
      seperator  = "<span class='arrow'><i class='fa fa-angle-right'></i></span>".html_safe
      out        = "".html_safe
      out       += link_to(I18n.t('fms.forums'), forum_root_path) + seperator
      if forum
        out     += link_to(forum.name, forum_path(forum))
        page     = session[:forum_page] ? session[:forum_page][forum.id] : nil
        if page and page != 1
          out   += "<small style='color:#ccc'>(".html_safe
          out   += link_to(I18n.t('fms.page_nr'), forum_path(:id => forum, :page => page))
          out   += ")</small>".html_safe
        end
        out += seperator
      end
      return out
    end

    #------------------------------------------------------------------------------
    def forum_topic_icon(forum_topic)
      if recent_topic_activity(forum_topic)
        style       = "style='color:green'"
        recent_txt  = I18n.t('fms.views_forums.recent_activity')
      else
        style       = ''
        recent_txt  = I18n.t('fms.views_forums.no_recent_activity')
      end
      if forum_topic.locked?
        "<i class='fa fa-lock fa-lg' #{style} title='#{I18n.t('fms.views_forums.comma_locked_topic')}'></i>".html_safe
      else
        "<i class='fa fa-comments fa-lg' #{style} title='#{recent_txt}'></i>".html_safe
      end
    end

    #------------------------------------------------------------------------------
    def forum_comment_user_state(forum_comment)
      if forum_comment.user.is_admin?
        I18n.t 'fms.user_is_administrator', :default => 'Administator'
      elsif can?(:moderate, forum_comment.forum_topic.forum)
        I18n.t 'fms.user_is_moderator', :default => 'Moderator'
      elsif forum_comment.user.suspended?
        forum_comment.user.state
      end
    end
  end
end
