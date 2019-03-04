namespace :settings do

  desc "Changes Setting key per_page_code for per_page_code_head"
  task per_page_code_migration: :environment do
    per_page_code_setting = Setting.where(key: "per_page_code").first
    per_page_code_setting_blank = Setting.where(key: "per_page_code_head").first.blank?

    Setting["per_page_code_head"] = per_page_code_setting&.value.to_s if per_page_code_setting_blank
    per_page_code_setting.destroy if per_page_code_setting.present?
  end

  desc "Create new Attached Documents feature setting"
  task create_attached_documents_setting: :environment do
    Setting["feature.allow_attached_documents"] = true
  end

  desc "Enable recommendations settings"
  task enable_recommendations: :environment do
    Setting["feature.user.recommendations"] = true
    Setting["feature.user.recommendations_on_debates"] = true
    Setting["feature.user.recommendations_on_proposals"] = true
  end

  desc "Enable Help page"
  task enable_help_page: :environment do
    Setting["feature.help_page"] = true
  end

  desc "Enable Featured proposals"
  task enable_featured_proposals: :environment do
    Setting["feature.featured_proposals"] = true
    Setting["featured_proposals_number"] = 3
  end

  desc "Create new period to calculate hot_score"
  task create_hot_score_period_setting: :environment do
    Setting["hot_score_period_in_days"] = 31
  end

  desc "Remove deprecated settings"
  task remove_deprecated_settings: :environment do
    deprecated_keys = [
      "place_name",
      "banner-style.banner-style-one",
      "banner-style.banner-style-two",
      "banner-style.banner-style-three",
      "banner-img.banner-img-one",
      "banner-img.banner-img-two",
      "banner-img.banner-img-three",
      "verification_offices_url"
    ]

    deprecated_keys.each do |key|
      setting = Setting.where(key: key).first
      if setting.present?
        setting.destroy
      end
    end
  end

end
