# Extends the Registration model with a state machine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module RegistrationStateEmail
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      #------------------------------------------------------------------------------
      included do

        #------------------------------------------------------------------------------
        def to_liquid
          result = {
            # 'price'         => (self.workshop_price.nil? ? '' : (self.event_payment.country.currency_format || '$%n').sub('%n', self.event_payment.amount.to_s)),
            'receipt_code'   => receipt_code.to_s,
            'price_desc'     => "#{workshop_price.price_desc unless workshop_price.nil?}",
            'title'          => workshop.title,
            'fullname'       => user.full_name
            # 'balance'        => balance_owed(true)
          }
          # result['arrival_date'] = format_date(arrival_at, true) if event_workshop.show_arrival_departure
          # result['departure_date'] = format_date(departure_at, true) if event_workshop.show_arrival_departure
    
          # TODO This is a security hole.  Any customer field data needs to be sanitized
          # custom_fields.each do | x |
          #   result[x.column_name] = x.data
          # end
    
          return result
        end

        # Send an email for state notification
        #------------------------------------------------------------------------------
        def email_state_notification(state = aasm.current_state.to_s)
          system_email = workshop.send("#{state}_email")
          if system_email
            receipt_content = compile_email(state, system_email)

            return RegistrationNotifyMailer.registration_notify(self, receipt_content[:content], receipt_content[:substitutions]).deliver
          end
        end

        # Compile the email values
        #------------------------------------------------------------------------------
        def compile_email(state, system_email)
          substitutions = {
            'state'   => state.to_s,
            'event'   => self.to_liquid
          }
          substitutions['payment_instructions'] = Liquid::Template.parse(workshop.payment_instructions).render(substitutions) unless workshop.payment_instructions.blank?
          substitutions['subject']              = Liquid::Template.parse(system_email.subject).render(substitutions)

          template  = Liquid::Template.parse(system_email.body)
          content   = template.render(substitutions)
          return {:content => content, :substitutions => substitutions}
        end

      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end
