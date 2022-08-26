class AUE::Goals::IconComponent < ApplicationComponent
  attr_reader :goal
  delegate :code, to: :goal

  def initialize(goal)
    @goal = goal
  end

  def image_path
    if svg_available?
      svg_path(locale)
    else
      png_path(locale)
    end
  end

  def title
    t("aue.goals.goal_#{code}.title")
  end

  def description
    t("aue.goals.goal_#{code}.description")
  end

  private

    def image_text
      goal.code_and_title
    end

    def locale
      @locale ||= [*I18n.fallbacks[I18n.locale], "default"].find do |fallback|
        AssetFinder.find_asset(svg_path(fallback)) ||
          AssetFinder.find_asset(png_path(fallback))
      end
    end

    def svg_available?
      puts locale
      puts svg_path(locale)
      AssetFinder.find_asset(svg_path(locale))
    end

    def svg_path(locale)
      "#{base_path(locale)}.svg"
    end

    def png_path(locale)
      "#{base_path(locale)}.png"
    end

    def base_path(locale)
      "aue/#{locale}/goal_#{code}"
    end
end
