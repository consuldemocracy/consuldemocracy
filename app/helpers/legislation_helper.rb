module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y") if date
  end

  def format_date_for_calendar_form(date)
    l(date, format: "%d/%m/%Y") if date
  end

  def new_legislation_proposal_link_text(process)
    if process.title == "PLENO ABIERTO"
      t("proposals.index.start_proposal_question")
    else
      t("proposals.index.start_proposal")
    end
  end

  def link_to_toggle_legislation_proposal_selection(proposal)
    if proposal.selected?
      button_text = t("admin.legislation.proposals.index.selected")
      html_class = 'button expanded'
    else
      button_text = t("admin.legislation.proposals.index.select")
      html_class = 'button hollow expanded'
    end

    link_to button_text,
      toggle_selection_admin_legislation_process_proposal_path(proposal.process, proposal),
      remote: true,
      method: :patch,
      class:  html_class
  end

  def legislation_process_tabs(process)
    {
      "info"           => edit_admin_legislation_process_path(process),
      "homepage"       => edit_admin_legislation_process_homepage_path(process),
      "questions"      => admin_legislation_process_questions_path(process),
      "proposals"      => admin_legislation_process_proposals_path(process),
      "draft_versions" => admin_legislation_process_draft_versions_path(process),
      "milestones"     => admin_legislation_process_milestones_path(process)
    }
  end

  def banner_color?
    @process.background_color.present? && @process.font_color.present?
  end

  def default_bg_color
    "#e7f2fc"
  end

  def default_font_color
    "#222222"
  end

  def bg_color_or_default
    @process.background_color.present? ? @process.background_color : default_bg_color
  end

  def font_color_or_default
    @process.font_color.present? ? @process.font_color : default_font_color
  end

  def css_for_process_header
    if banner_color?
      "background:" + @process.background_color + ";color:" + @process.font_color + ";"
    end
  end

end
