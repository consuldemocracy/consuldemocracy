module Custom::ProbeHelper

  def css_for_link_to_display_hidden_project
    @discarded_probe_option_ids.any? ? 'display:inline-block;' : 'display:none;'
  end

  def css_for_discarded_probe_option(probe_option)
    @discarded_probe_option_ids.include?(probe_option.id) ? 'display:none;' : 'display:initial;'
  end

end