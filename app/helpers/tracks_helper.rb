module TracksHelper

  def track_event(category, action, name=nil, custom_value=nil, dimension=nil, dimension_value=nil)
    content_for :track_event_category do
      category
    end

    content_for :track_event_action do
      action
    end

    content_for :track_event_name do
      name
    end

    content_for :track_event_custom_value do
      custom_value
    end

    content_for :track_event_dimension do
      dimension
    end

    content_for :track_event_dimension_value do
      dimension_value
    end
  end

  def gender(user)
    if user.gender.present?
      I18n.t("tracking.user_data.gender.#{gender}")
    else
      I18n.t("tracking.user_data.gender.unknown")
    end
  end

  def age(user)
    if user.date_of_birth.blank?
      I18n.t("tracking.user_data.age.unknown")
    else
      ((Date.today - user.date_of_birth.to_date).to_i / 365.25).to_i
    end
  end

  def verification_level(user)
    case
    when user.sms_verified?
      I18n.t("tracking.user_data.verification_level.level_three")
    when user.residence_verified?
      I18n.t("tracking.user_data.verification_level.level_two")
    else
      I18n.t("tracking.user_data.verification_level.level_one")
    end
  end

  def geozone(user)
    current_user.try(:geozone).try(:name) || I18n.t("tracking.user_data.district.unknown")
  end

end