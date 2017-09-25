class Officing::PollsController < Officing::BaseController

  def index
    @polls = current_user.poll_officer? ? current_user.poll_officer.voting_days_assigned_polls : []
    @polls = @polls.select {|poll| poll.current?(Time.current) || poll.current?(1.day.ago)}
  end

  def final
    @polls = if current_user.poll_officer?
               current_user.poll_officer.final_days_assigned_polls.select {|poll| poll.ends_at > 2.weeks.ago && poll.expired?}
             else
               []
             end
  end

end
