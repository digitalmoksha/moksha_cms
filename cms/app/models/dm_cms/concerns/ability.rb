# Wrap blog/cms specific CanCan rules.  Should be included in the main app's
# Ability class.
# NOTE:  When checking abilities, don't check for Class level abilities,
# unless you don't care about the instance level.  For example, don't
# use both styles
#   can? :moderate, Forum
#   can? :moderate, @forum
# In this case, if you need to check the class level, then use specific
#    current_user.has_role? :moderator, Forum
#------------------------------------------------------------------------------
module DmCms
  module Concerns
    module Ability
      extend ActiveSupport::Concern

      included do
        def dm_cms_abilities(user)
          if user
            #--- Admin
            if user.has_role?(:content_manager)
              can :access_content_section, :all
              can :manage_content, :all
              can :access_media_library, :all
              can :access_admin, :all
            elsif user.has_role?(:content_manager_alacarte)
              # allowed to access the backend content section
              can :access_content_section, :all
              can :access_admin, :all

              # can edit a page
              manage_page_ids = @user_roles.select { |r| r.name == 'manage_content' && r.resource_type == 'CmsPage' }.map(&:resource_id)
              can :manage_content, CmsPage, id: manage_page_ids
              can(:access_media_library, :all) unless manage_page_ids.empty?

              # can edit a blog
              manage_blog_ids = @user_roles.select { |r| r.name == 'manage_content' && r.resource_type == 'CmsBlog' }.map(&:resource_id)
              can :manage_content, CmsBlog, id: manage_blog_ids
              can :read, CmsBlog, id: manage_blog_ids
              can(:access_media_library, :all) unless manage_blog_ids.empty?
            end

            #--- Blog
            can(:read,  CmsBlog)  { |blog| blog.can_be_read_by?(user) }
            can(:reply, CmsBlog)  { |blog| blog.can_be_replied_by?(user) }
            # can :moderate, CmsBlog, :id => CmsBlog.published.with_role(:moderator, user).map(&:id)

            can(:read, CmsPost)   { |post| post.is_published? || user.has_role?(:reviewer) || user.has_role?(:content_manager) }

            #--- Pages
            can(:read, CmsPage)   { |page| page.is_published? || user.has_role?(:reviewer) || user.has_role?(:content_manager) }
          else
            #--- can only read/see public blogs when not logged in
            can(:read, CmsBlog)   { |blog| blog.can_be_read_by?(user) }
            can(:read, CmsPost, &:is_published?)
            can(:read, CmsPage, &:is_published?)
          end
        end
      end

      ::Ability.register_abilities(:dm_cms_abilities)
    end
  end
end

#------------------------------------------------------------------------------
# The abilities get basically compiled.  So if you use
#
#    can :moderate, Forum, :id => Forum.with_role(:moderator, user).map(&:id)
#
# this will execute the Forum.with_role query once during Ability.new.  However
#
#    can :moderate, Forum do |forum|
#      user.has_role? :moderator, forum
#    end
#
# this will execute the has_role? block on each call to can?
