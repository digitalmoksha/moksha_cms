module DmEvent::RegistrationsHelper
  #------------------------------------------------------------------------------
  def price_details(workshop_price)
    render partial: 'dm_event/registrations/workshop_price', object: workshop_price
  end

  #------------------------------------------------------------------------------
  def status_label(text, state = :plain, with_icon = true)
    icons = { acceptedx: 'fa fa-thumbs-up' }.freeze
    icon = icons[state.to_sym]
    colored_label(icon_label(icon, text, color: '#fff'), state)
  end
end
