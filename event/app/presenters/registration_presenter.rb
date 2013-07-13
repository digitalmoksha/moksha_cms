#------------------------------------------------------------------------------
class RegistrationPresenter < EventCommonPresenter
  presents  :model
  
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
    h.colored_label(model.current_state.to_s.titlecase, "#{model.current_state}")
  end

end