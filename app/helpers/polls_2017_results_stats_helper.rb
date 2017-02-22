module Polls2017ResultsStatsHelper

  def total_votes_for_answer(question, answer)
    ::Poll::PartialResult.where(question_id: question.id).where(answer: answer).sum(:amount)
  end

  def total_votes_for_poll(poll)
    ::Poll::FinalRecount.where(booth_assignment_id: poll.booth_assignment_ids).sum(:count)
  end
end