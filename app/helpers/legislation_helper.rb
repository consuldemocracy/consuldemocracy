module LegislationHelper
  def format_date(date)
    l(date, format: "%d %h %Y") if date
  end

  def format_date_for_calendar_form(date)
    l(date, format: "%d/%m/%Y") if date
  end

  def new_legislation_proposal_link_text(process)
    t("proposals.index.start_proposal")
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
end
