class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  include Admin::SwitchText
  attr_reader :feature, :tab, :describedby
  alias_method :describedby?, :describedby

  def initialize(feature, tab: nil, describedby: true)
    @feature = feature
    @tab = tab
    @describedby = describedby
  end

  private

    def checked?
      feature.enabled?
    end

    def options
      {
        data: { disable_with: text },
        "aria-labelledby": dom_id(feature, :title),
        "aria-describedby": (dom_id(feature, :description) if describedby?),
        "aria-pressed": checked?
      }
    end

    def remote?
      !%w[feature.map feature.remote_census feature.sdg].include?(feature.key)
    end
end
