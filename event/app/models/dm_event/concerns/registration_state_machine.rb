# Extends the Registration model with a state machine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module RegistrationStateMachine
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      #------------------------------------------------------------------------------
      included do
        include AASM

        #--- define how the state machine works
        aasm do
          state :open,                :initial => true, :after_enter => Proc.new { |o| o.start! }
          state :pending,             :after_enter => :state_pending
          state :reviewing,           :after_enter => :state_reviewing
          state :accepted,            :after_enter => :state_acceptance
          state :rejected,            :after_enter => :state_rejection
          state :paid,                :after_enter => :state_paid
          state :waitlisted,          :after_enter => :state_waitlisted
          state :canceled,            :after_enter => :state_canceled
          state :refunded,            :after_enter => :state_refunded
          state :noshow,              :after_enter => :state_noshow

          #------------------------------------------------------------------------------
          event :start do
            transitions :from => :open,       :to => :waitlisted, :guard => Proc.new {|o| o.workshop.waitlisting?}   
            transitions :from => :open,       :to => :pending,    :guard => Proc.new {|o| o.workshop.require_review?}   
            transitions :from => :open,       :to => :accepted
          end
  
          #------------------------------------------------------------------------------
          event :review do
            transitions :from => :pending,    :to => :reviewing
            transitions :from => :accepted,   :to => :reviewing
            transitions :from => :rejected,   :to => :reviewing
            transitions :from => :waitlisted, :to => :reviewing
            transitions :from => :canceled,   :to => :reviewing
            transitions :from => :refunded,   :to => :reviewing
            transitions :from => :noshow,     :to => :reviewing
          end  
    
          #------------------------------------------------------------------------------
          event :accept do
            transitions :from => :pending,    :to => :accepted
            transitions :from => :paid,       :to => :accepted
            transitions :from => :reviewing,  :to => :accepted
            transitions :from => :rejected,   :to => :accepted
            transitions :from => :waitlisted, :to => :accepted
            transitions :from => :canceled,   :to => :accepted
            transitions :from => :refunded,   :to => :accepted
            transitions :from => :noshow,     :to => :accepted
          end  
  
          #------------------------------------------------------------------------------
          event :paid do
            transitions :from => :pending,    :to => :paid
            transitions :from => :reviewing,  :to => :paid
            transitions :from => :accepted,   :to => :paid
            transitions :from => :paid,       :to => :paid
            transitions :from => :rejected,   :to => :paid
            transitions :from => :refunded,   :to => :paid
            transitions :from => :noshow,     :to => :paid
            transitions :from => :waitlisted, :to => :paid
          end
    
          #------------------------------------------------------------------------------
          event :refund do
            transitions :from => :paid,       :to => :refunded
            transitions :from => :canceled,   :to => :refunded
            transitions :from => :accepted,   :to => :refunded
            transitions :from => :pending,    :to => :refunded
            transitions :from => :reviewing,  :to => :refunded
            transitions :from => :waitlisted, :to => :refunded
          end
    
          #------------------------------------------------------------------------------
          event :reject do
            transitions :from => :pending,    :to => :rejected
            transitions :from => :reviewing,  :to => :rejected
            transitions :from => :waitlisted, :to => :rejected
            transitions :from => :canceled,   :to => :rejected
          end

          #------------------------------------------------------------------------------
          event :cancellation do
            transitions :from => :accepted,   :to => :canceled
            transitions :from => :pending,    :to => :canceled
            transitions :from => :reviewing,  :to => :canceled
            transitions :from => :paid,       :to => :canceled
            transitions :from => :waitlisted, :to => :canceled
            transitions :from => :rejected,   :to => :canceled
            transitions :from => :noshow,     :to => :canceled
          end

          #------------------------------------------------------------------------------
          event :waitlist do
            transitions :from => :pending,    :to => :waitlisted
            transitions :from => :reviewing,  :to => :waitlisted
            transitions :from => :rejected,   :to => :waitlisted
            transitions :from => :accepted,   :to => :waitlisted
            transitions :from => :canceled,   :to => :waitlisted
            transitions :from => :paid,       :to => :waitlisted
          end

          #------------------------------------------------------------------------------
          event :noshow do
            transitions :from => :pending,    :to => :noshow
            transitions :from => :reviewing,  :to => :noshow
            transitions :from => :accepted,   :to => :noshow
            transitions :from => :rejected,   :to => :noshow
            transitions :from => :paid,       :to => :noshow
            transitions :from => :canceled,   :to => :noshow
            transitions :from => :waitlisted, :to => :noshow
            transitions :from => :refunded,   :to => :noshow
          end

          #------------------------------------------------------------------------------
          event :pending do
            transitions :from => :reviewing,  :to => :pending
            transitions :from => :waitlisted, :to => :pending
          end

        end
        
        #------------------------------------------------------------------------------
        def current_state
          aasm.current_state
        end
        
        # send the email if it's defined
        #------------------------------------------------------------------------------
        def state_pending
          update_state_date
          email_state_notification(:pending)
        end

        #------------------------------------------------------------------------------
        def state_reviewing
          update_state_date
        end

        # send the email if it's defined
        #------------------------------------------------------------------------------
        def state_acceptance
          update_state_date
          email_state_notification(:accepted) unless @suppress_transition_email
        end

        # send the email if it's defined
        #------------------------------------------------------------------------------
        def state_rejection
          update_state_date
          email_state_notification(:rejected)
        end

        # send the email if it's defined
        #------------------------------------------------------------------------------
        def state_paid
          update_state_date
          email_state_notification(:paid)
        end

        # send the email if it's defined
        #------------------------------------------------------------------------------
        def state_waitlisted
          update_state_date
          email_state_notification(:waitlisted)
        end

        #------------------------------------------------------------------------------
        def state_canceled
          update_state_date
        end

        #------------------------------------------------------------------------------
        def state_refunded
          update_state_date
        end

        #------------------------------------------------------------------------------
        def state_noshow
          update_state_date
        end
        
        #------------------------------------------------------------------------------
        def update_state_date
          update_attribute(:process_changed_on, Time.now)
        end
        
        #------------------------------------------------------------------------------
        def attending?
          aasm_state == 'accepted' || aasm_state == 'paid'
        end
  
        # return true if they have registered
        #------------------------------------------------------------------------------
        def registered?
          aasm_state == 'pending' || aasm_state == 'waitlisted' || attending?
        end

        # don't send a the notification email during a state transition
        #------------------------------------------------------------------------------
        def suppress_transition_email
          @suppress_transition_email = true
        end
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end
