module DmEvent::WorkshopsHelper
  
  #------------------------------------------------------------------------------
  def render_workshop_description(workshop)
    if workshop.description.nil?
      description = ""
    else
      # --- process as markdown
      x           = render :inline => workshop.description
      description = liquidize_markdown(x, {})
    end
    return description
  end

end
