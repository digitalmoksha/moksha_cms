# Extends the Registration model with email notifications
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module RegistrationStateEmail
      extend ActiveSupport::Concern
      include DmUtilities::DateHelper

      included do
        #------------------------------------------------------------------------------
        def to_liquid
          result = {
            'price'               => (workshop_price.nil? ? '' : workshop_price.price_formatted),
            'receipt_code'        => receipt_code.to_s,
            'price_description'   => (workshop_price&.price_description).to_s,
            'discount'            => discount.format(no_cents_if_whole: true, symbol: true),
            'discounted_price'    => discounted_price.format(no_cents_if_whole: true, symbol: true),
            'title'               => workshop.title,
            'fullname'            => user_profile.full_name,
            'payment_url'         => self.payment_url,
            'balance'             => self.balance_owed.format,
            'payment_owed'        => self.payment_owed.format,
            'start_date'          => format_date(workshop.starting_on, true),
            'end_date'            => format_date(workshop.ending_on, true),
            'start_time'          => format_time(workshop.starting_on),
            'end_time'            => format_time(workshop.ending_on),
            'date_range'          => format_date_range(workshop.starting_on, workshop.ending_on)
          }

          return result
        end

        # Send an email for state notification.  if send_email is false, just return
        # the content of the email
        #------------------------------------------------------------------------------
        def email_state_notification(state = aasm.current_state.to_s, send_email = true)
          I18n.with_locale(registered_locale) do
            system_email = workshop.send("#{state}_email")
            if system_email
              receipt_content = compile_email(state, system_email)
              if send_email
                return RegistrationNotifyMailer.registration_notify(self, receipt_content[:content], receipt_content[:substitutions]).deliver_now
              else
                return receipt_content[:content]
              end
            end
          end
        end

        # Compile the email values
        #------------------------------------------------------------------------------
        def compile_email(state, system_email)
          substitutions = {
            'state'   => state.to_s,
            'event'   => self.to_liquid
          }
          substitutions['payment_details'] = Liquid::Template.parse(workshop_price.payment_details).render(substitutions) unless workshop_price.try(:payment_details).blank?
          substitutions['subject']         = Liquid::Template.parse(system_email.subject).render(substitutions)

          template  = Liquid::Template.parse(system_email.body)
          content   = template.render(substitutions)
          return { :content => content, :substitutions => substitutions }
        end
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end
    end
  end
end
