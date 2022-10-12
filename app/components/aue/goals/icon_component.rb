class AUE::Goals::IconComponent < ApplicationComponent
  attr_reader :goal
  delegate :code, to: :goal

  def initialize(goal)
    @goal = goal
  end

  def image_path
    if svg_available?
      svg_path()
    end
  end

  private

    def image_text
      goal.code_and_title
    end

    def svg_available?
      AssetFinder.find_asset(svg_path())
    end

    def svg_path()
      "#{base_path()}.svg"
    end

    def base_path()
      "aue/goal_#{code}"
    end
end
