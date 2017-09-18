module DmEvent::Workshops
  class CreateService
    include DmCore::ServiceSupport

    #------------------------------------------------------------------------------
    def initialize(params)
      @params = params.dup
    end

    #------------------------------------------------------------------------------
    def call
      @workshop = Workshop.new(@params)
      @workshop.save
      @workshop
    end

  end
end
  