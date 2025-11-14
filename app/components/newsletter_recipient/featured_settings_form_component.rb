class NewsletterRecipient::FeaturedSettingsFormComponent < ApplicationComponent
  attr_reader :feature, :user, :value

  def initialize(feature, user)
    @feature = feature
    @user = user
    @value = user.try(feature)
  end

  def enabled?
    value
  end

  private

    def text
      value ? t("shared.yes") : t("shared.no")
    end

    def options
      {
        "aria-pressed": !!value,
        id: "newsletter-recipient-btn",
        name: "Newsletter recipient",
        "data-yes": t("shared.yes"),
        "data-no": t("shared.no")
      }
    end
end
