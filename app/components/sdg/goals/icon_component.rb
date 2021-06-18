class SDG::Goals::IconComponent < ApplicationComponent
  attr_reader :goal
  delegate :code, to: :goal

  def initialize(goal)
    @goal = goal
  end

  def image_path
    "sdg/#{locale}/goal_#{code}.png"
  end

  private

    def image_text
      goal.code_and_title
    end

    def locale
      [*I18n.fallbacks[I18n.locale], "default"].find do |fallback|
        AssetFinder.find_asset("sdg/#{fallback}/goal_#{code}.png")
      end
    end
end
