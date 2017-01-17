module Custom::ProbeHelper

  def css_for_link_to_display_hidden_project
    @discarded_probe_option_ids.any? ? 'display:inline-block;' : 'display:none;'
  end

  def css_for_discarded_probe_option(probe_option)
    @discarded_probe_option_ids.include?(probe_option.id) ? 'display:none;' : 'display:initial;'
  end

  def finalist?(probe_option)
    ["03","10","28","30","68"].include? probe_option.code
  end

  def external_pdf?(probe_option)
    probe_option.code == "30"
  end

  def project_x?(probe_option)
    probe_option.code == "30"
  end

  def project_y?(probe_option)
    probe_option.code == "10"
  end
end