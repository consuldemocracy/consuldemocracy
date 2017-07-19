module FollowsHelper

  def follow_text(followable)
    entity = followable.class.name.underscore
    t('shared.follow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def unfollow_text(followable)
    entity = followable.class.name.underscore
    t('shared.unfollow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def follow_link_wrapper_id(followable)
    "follow-expand-#{followable_full_name(followable)}-#{followable.id}"
  end

  def unfollow_link_wrapper_id(followable)
    "unfollow-expand-#{followable_full_name(followable)}-#{followable.id}"
  end

  def follow_link_id(followable)
    "follow-#{followable_full_name(followable)}-#{followable.id}"
  end

  def unfollow_link_id(followable)
    "unfollow-#{followable_full_name(followable)}-#{followable.id}"
  end

  def follow_drop_id(followable)
    "follow-drop-#{followable_full_name(followable)}-#{followable.id}"
  end

  def unfollow_drop_id(followable)
    "unfollow-drop-#{followable_full_name(followable)}-#{followable.id}"
  end

  def entity_title(title)
    t("activerecord.models.#{title.underscore}.other")
  end

end
