class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  def type
    prefix = key.split(".").first
    if %w[feature process proposals map html homepage].include? prefix
      prefix
    else
      "configuration"
    end
  end

  def enabled?
    value.present?
  end

  class << self
    def [](key)
      where(key: key).pluck(:value).first.presence
    end

    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value.presence
      setting.save!
      value
    end

    def rename_key(from:, to:)
      if where(key: to).empty?
        value = where(key: from).pluck(:value).first.presence
        create!(key: to, value: value)
      end
      remove(from)
    end

    def remove(key)
      setting = where(key: key).first
      setting.destroy if setting.present?
    end

    def defaults
      {
        "comments_body_max_length": 1000,
        "dashboard.emails": nil,
        "direct_message_max_per_day": 3,
        # Users with this email domain will automatically be marked as level 1 officials
        # Emails under the domain's subdomains will also be included
        "email_domain_for_officials": "",
        "facebook_handle": nil,
        "feature.allow_attached_documents": true,
        "feature.allow_images": true,
        "feature.community": true,
        "feature.facebook_login": true,
        "feature.featured_proposals": nil,
        "feature.google_login": true,
        "feature.help_page": true,
        "feature.map": nil,
        "feature.public_stats": true,
        "feature.signature_sheets": true,
        "feature.twitter_login": true,
        "feature.user.recommendations": true,
        "feature.user.recommendations_on_debates": true,
        "feature.user.recommendations_on_proposals": true,
        "feature.user.skip_verification": "true",
        "featured_proposals_number": 3,
        "homepage.widgets.feeds.debates": true,
        "homepage.widgets.feeds.processes": true,
        "homepage.widgets.feeds.proposals": true,
        "hot_score_period_in_days": 31,
        # Code to be included at the top (inside <body>) of every page
        "html.per_page_code_body": "",
        # Code to be included at the top (inside <head>) of every page (useful for tracking)
        "html.per_page_code_head": "",
        "instagram_handle": nil,
        "mailer_from_address": "noreply@consul.dev",
        "mailer_from_name": "CONSUL",
        "map.latitude": 51.48,
        "map.longitude": 0.0,
        "map.zoom": 10,
        "max_ratio_anon_votes_on_debates": 50,
        "max_votes_for_debate_edit": 1000,
        "max_votes_for_proposal_edit": 1000,
        "meta_description": nil,
        "meta_keywords": nil,
        "meta_title": nil,
        "min_age_to_participate": 16,
        "months_to_archive_proposals": 12,
        # Names for the moderation console, as a hint for moderators
        # to know better how to assign users with official positions
        "official_level_1_name": I18n.t("seeds.settings.official_level_1_name"),
        "official_level_2_name": I18n.t("seeds.settings.official_level_2_name"),
        "official_level_3_name": I18n.t("seeds.settings.official_level_3_name"),
        "official_level_4_name": I18n.t("seeds.settings.official_level_4_name"),
        "official_level_5_name": I18n.t("seeds.settings.official_level_5_name"),
        # CONSUL installation's organization name
        "org_name": "CONSUL",
        "process.budgets": true,
        "process.debates": true,
        "process.legislation": true,
        "process.polls": true,
        "process.proposals": true,
        "proposal_code_prefix": "CONSUL",
        "proposal_notification_minimum_interval_in_days": 3,
        "proposals.email_description": nil,
        "proposals.email_short_title": nil,
        "proposals.poll_description": nil,
        "proposals.poll_link": nil,
        "proposals.poll_short_title": nil,
        "proposals.poster_description": nil,
        "proposals.poster_short_title": nil,
        "proposals.successful_proposal_id": nil,
        "related_content_score_threshold": -0.3,
        "telegram_handle": nil,
        "twitter_handle": nil,
        "twitter_hashtag": nil,
        "url": "http://example.com", # Public-facing URL of the app.
        "votes_for_proposal_success": 10000,
        "youtube_handle": nil
      }
    end

    def reset_defaults
      defaults.each { |name, value| self[name] = value }
    end
  end
end
