module PollsHelper

  def poll_select_options(include_all=nil)
    options = @polls.collect {|poll|
      [poll.name, current_path_with_query_params(poll_id: poll.id)]
    }
    options << all_polls if include_all
    options_for_select(options, request.fullpath)
  end

  def all_polls
    [I18n.t("polls.all"), admin_questions_path]
  end

  def poll_dates(poll)
    if poll.starts_at.blank? || poll.ends_at.blank?
      I18n.t("polls.no_dates")
    else
      I18n.t("polls.dates", open_at: l(poll.starts_at.to_date), closed_at: l(poll.ends_at.to_date))
    end
  end

end