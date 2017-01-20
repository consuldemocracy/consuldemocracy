module CustomUrlsHelper
  def legislation_question_url(question)
    legislation_process_question_url(question.process, question)
  end

  def legislation_annotation_url(annotation)
    legislation_process_question_url(annotation.draft_version.process, annotation.draft_version, annotation)
  end
end
