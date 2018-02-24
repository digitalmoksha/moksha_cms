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

  #------------------------------------------------------------------------------
  def render_workshop_sidebar(workshop)
    return '' if workshop.sidebar.nil?

    liquidize_markdown(render(:inline => workshop.sidebar), {})
  end

  # Convert the financial "collected" data into json for pie charts
  #------------------------------------------------------------------------------
  def financial_collected_json(collected)
    json = []
    collected.sort.each do |item|
      json << { label: "#{item[0]}: #{item[1].format(:no_cents_if_whole => true, :symbol => true)}", data: item[1].to_f }
    end
    json.to_json
  end

  # Convert the financial "collected" data into json for pie charts
  #------------------------------------------------------------------------------
  def financial_collected_monthly_json(collected)
    json = []
    collected.sort.each do |item|
      json << [item[0].localize("%b").to_s, collected[item[0]].to_f]
    end
    json.to_json
  end
end
