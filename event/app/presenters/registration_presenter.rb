#------------------------------------------------------------------------------
class RegistrationPresenter < EventCommonPresenter
  presents :model

  #------------------------------------------------------------------------------
  # Admin presenter methods

  #------------------------------------------------------------------------------
  def label_published
    !model.registration_closed? ? h.colored_label(start_end_date, :success) : h.colored_label(start_end_date)
  end

  #------------------------------------------------------------------------------
  def start_end_date
    format_date_range(model.starting_on, model.ending_on)
  end

  #------------------------------------------------------------------------------
  def admin_status_label
    h.colored_label(model.current_state.to_s.titlecase, (model.current_state).to_s)
  end

  #------------------------------------------------------------------------------
  def balance_or_paid
    if model.workshop_price && model.workshop_price.price
      color = model.balance_owed.positive? ? 'balance_owed' : 'balance_paid'
      amount = model.balance_owed.zero? ? 'paid' : model.balance_owed.format(:no_cents_if_whole => true)
      "<span data-placement='left' class='hovertip #{color}' title='#{model.workshop_price.price.format(:no_cents_if_whole => true)} &mdash; #{model.workshop_price.price_description}'>#{amount}</span>".html_safe
    else
      '-'
    end
  end
end
