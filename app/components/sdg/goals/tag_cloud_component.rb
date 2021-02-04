class SDG::Goals::TagCloudComponent < ApplicationComponent
  attr_reader :class_name

  def initialize(class_name)
    @class_name = class_name
  end

  def render?
    SDG::ProcessEnabled.new(class_name).enabled?
  end

  private

    def heading
      t("sdg.goals.filter.heading")
    end

    def goals
      SDG::Goal.order(:code)
    end
end
