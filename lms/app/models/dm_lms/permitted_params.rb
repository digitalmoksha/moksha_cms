module DmLms
  module PermittedParams
    #------------------------------------------------------------------------------
    def course_params
      params.require(:course).permit! if can? :manage_courses, :all
    end

    #------------------------------------------------------------------------------
    def lesson_params
      params.require(:lesson).permit! if can? :manage_courses, :all
    end

    #------------------------------------------------------------------------------
    def teaching_params
      params.require(:teaching).permit! if can? :manage_courses, :all
    end
  end
end