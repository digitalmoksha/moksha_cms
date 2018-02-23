module DmEvent::Workshops
  class DestroyService
    include DmCore::ServiceSupport

    #------------------------------------------------------------------------------
    def initialize(workshop)
      @workshop = workshop
    end

    #------------------------------------------------------------------------------
    def call
      @workshop.destroy
    end
  end
end
