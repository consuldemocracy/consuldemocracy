class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  attr_reader :feature, :tab, :describedby
  alias_method :describedby?, :describedby
  delegate :enabled?, to: :feature

  def initialize(feature, tab: nil, describedby: true)
    @feature = feature
    @tab = tab
    @describedby = describedby
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
        "aria-describedby": (dom_id(feature, :description) if describedby?),
        "aria-pressed": enabled?
      }
    end
end
