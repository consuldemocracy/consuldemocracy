class AUE::Goals::TagCloudComponent < ApplicationComponent
  include SettingsHelper
  attr_reader :class_name

  def initialize(class_name)
    @class_name = class_name
  end

  def render?
    feature?("aue")
    # AUE::ProcessEnabled.new(class_name).enabled?
  end

  private

    def heading
      t("aue.goals.filter.heading")
    end

    def goals
      AUE::Goal.order(:code)
    end
end
