module FollowsHelper

  def follow_text(followable)
    entity = followable.class.name.underscore
    t('shared.follow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def unfollow_text(followable)
    entity = followable.class.name.underscore
    t('shared.unfollow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

end
