module FlagsHelper

  def show_flag_action?(flaggable)
    current_user && !own_flaggable?(flaggable) && !flagged?(flaggable)
  end

  def show_unflag_action?(flaggable)
    current_user && !own_flaggable?(flaggable) && flagged?(flaggable)
  end

  private

  def flagged?(flaggable)
    if flaggable.is_a? Comment
      @comment_flags[flaggable.id] unless flaggable.commentable_type == "Poll"
    else
      Flag.flagged?(current_user, flaggable)
    end
  end

  def own_flaggable?(flaggable)
    if flaggable.is_a? Comment
      flaggable.user_id == current_user.id
    else
      flaggable.author_id == current_user.id
    end
  end

end
