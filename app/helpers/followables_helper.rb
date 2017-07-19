module FollowablesHelper

  def show_follow_action?(followable)
    current_user && !followed?(followable)
  end

  def show_unfollow_action?(followable)
    current_user && followed?(followable)
  end

  def followable_type_title(followable_type)
    t("activerecord.models.#{followable_type.underscore}.other")
  end

  def followable_icon(followable)
    {
      proposals: 'Proposal',
      budget: 'Budget::Investment'
    }.invert[followable]
  end

  def render_follow(follow)
    followable = follow.followable
    partial = followable_class_name(followable)
    locals = {followable_class_name(followable).to_sym => followable}

    render partial, locals
  end

  def followable_class_name(followable)
    followable.class.to_s.parameterize.gsub('-', '_')
  end

  private

    def followed?(followable)
      Follow.followed?(current_user, followable)
    end

end
