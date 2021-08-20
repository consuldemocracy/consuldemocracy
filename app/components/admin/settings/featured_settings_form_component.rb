class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  attr_reader :feature, :tab

  def initialize(feature, tab: nil)
    @feature = feature
    @tab = tab
  end
end
