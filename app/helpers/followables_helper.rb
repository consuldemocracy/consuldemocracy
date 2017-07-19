module FollowablesHelper

  def show_follow_action?(followable)
    current_user && !followed?(followable)
  end

  def show_unfollow_action?(followable)
    current_user && followed?(followable)
  end

  def entity_title(title)
    t("activerecord.models.#{title.underscore}.other")
  end

  def followable_full_name(followable)
    followable.class.name.parameterize
  end

  def followable_title(followable)
    entity = followable.class.name.underscore
    t('shared.followable_title', entity: t("activerecord.models.#{entity}.one").downcase)
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
