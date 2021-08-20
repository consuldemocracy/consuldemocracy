class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  attr_reader :feature, :tab
  delegate :enabled?, to: :feature

  def initialize(feature, tab: nil)
    @feature = feature
    @tab = tab
  end

  private

    def text
      if enabled?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    def options
      {
        "aria-labelledby": dom_id(feature, :title),
        "aria-describedby": dom_id(feature, :description),
        "aria-pressed": enabled?
      }
    end
end
