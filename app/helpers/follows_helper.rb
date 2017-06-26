module FollowsHelper

  def show_follow_action?(followable)
    current_user && !followed?(followable)
  end

  def show_unfollow_action?(followable)
    current_user && followed?(followable)
  end

  def follow_entity_text(entity)
    t('shared.follow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def unfollow_entity_text(entity)
    t('shared.unfollow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def entity_name(followable)
    followable.class.name.downcase
  end
  private

    def followed?(followable)
      Follow.followed?(current_user, followable)
    end

end
