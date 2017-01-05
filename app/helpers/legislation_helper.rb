module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y") if date
  end

  def format_date_for_calendar_form(date)
    l(date, format: "%d/%m/%Y") if date
  end

  def legislation_question_path(question)
    legislation_process_question_path(question.process, question)
  end

  def legislation_annotation_path(annotation)
    legislation_process_draft_version_annotation_path(annotation.draft_version.process, annotation.draft_version, annotation)
  end
end
