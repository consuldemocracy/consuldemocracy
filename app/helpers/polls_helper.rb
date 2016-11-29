module PollsHelper

  def poll_select_options(include_all=nil)
    options = @polls.collect {|poll|
      [poll.name, current_path_with_query_params(poll_id: poll.id)]
    }
    options << all_polls if include_all
    options_for_select(options, request.fullpath)
  end

  def all_polls
    ["Todas", admin_questions_path]
  end

end