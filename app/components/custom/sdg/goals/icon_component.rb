class SDG::Goals::IconComponent < ApplicationComponent
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
      AssetFinder.find_asset(svg_path(locale))
    end

    def svg_path(locale)
      "#{base_path(locale)}.svg"
    end

    def png_path(locale)
      "#{base_path(locale)}.png"
    end

    def base_path(locale)
      "sdg/#{locale}/goal_#{code}"
    end
end
