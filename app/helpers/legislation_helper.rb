module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y") if date
  end

  def legislation_question_path(question)
    legislation_process_question_path(question.process, question)
  end
end
