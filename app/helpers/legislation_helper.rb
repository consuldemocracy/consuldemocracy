module LegislationHelper
  def format_date(date)
    l(date, format: "%d %h %Y") if date
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
end
