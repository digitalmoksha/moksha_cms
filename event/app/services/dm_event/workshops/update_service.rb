module DmEvent::Workshops
  class UpdateService
    include DmCore::ServiceSupport

    #------------------------------------------------------------------------------
    def initialize(workshop, params, options = {})
      @workshop, @params, @options = workshop, params.dup, options
    end

    #------------------------------------------------------------------------------
    def call
      if @workshop.valid?
        prepare_additional_parameters if @options[:additional_configuration]
        return @workshop.update_attributes(@params)
      else
        false
      end
    end

  private
    
    # blindly saving these would erase them when updating the workshop on the
    # normal page.  Only do on the additional configuration page
    #------------------------------------------------------------------------------
    def prepare_additional_parameters
      new_blog_id = @params.delete(:cms_blog).to_i
      if @workshop.cms_blog.try(:id) != new_blog_id
        @workshop.cms_blog = new_blog_id == 0 ? nil : ::CmsBlog.find(new_blog_id)
      end

      if defined?(Forum)
        new_forum_id = @params.delete(:forum).to_i
        if @workshop.forum.try(:id) != new_forum_id
          @workshop.forum = new_forum_id == 0 ? nil : ::Forum.find(new_forum_id)
        end
      end

      if defined?(DmLms)
        new_course_id = @params.delete(:course).to_i
        if @workshop.course.try(:id) != new_course_id
          @workshop.course = new_course_id == 0 ? nil : ::Course.find(new_course_id)
        end
      end

      # remove any extra "custom_field" attributes left during the field definition
      if @params[:custom_field_defs_attributes]
        byebug
        @params[:custom_field_defs_attributes].each_pair {|key, value| @params[:custom_field_defs_attributes][key].delete(:custom_field)}
      end
    end
  end
end
  