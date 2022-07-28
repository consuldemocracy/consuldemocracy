module Maps
  def fill_in_proposal_form
    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
  end

  def submit_proposal_form
    check :proposal_terms_of_service
    click_button "Create proposal"

    if page.has_content?("Not now, go to my proposal")
      click_link "Not now, go to my proposal"
    end
  end

  def fill_in_budget_investment_form
    fill_in_new_investment_title with: "Budget investment title"
    fill_in_ckeditor "Description", with: "Budget investment description"
    check :budget_investment_terms_of_service
  end

  def submit_budget_investment_form
    check :budget_investment_terms_of_service
    click_button "Create Investment"
  end

  def set_arguments(arguments, mappable, mappable_path_arguments)
    mappable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": mappable.send(path_to_value))
    end
  end

  def map_zoom_in
    initial_zoom = page.execute_script("return App.Map.maps[0].getZoom();")
    find(".leaflet-control-zoom-in").click
    until page.execute_script("return App.Map.maps[0].getZoom() === #{initial_zoom + 1};") do
      sleep 0.01
    end
  end

  def place_map_at(latitude, longitude)
    page.execute_script("App.Map.maps[0].setView(new L.LatLng(#{latitude}, #{longitude}))")

    until page.execute_script("return App.Map.maps[0].getCenter().lat === #{latitude};") do
      sleep 0.01
    end
  end
end
