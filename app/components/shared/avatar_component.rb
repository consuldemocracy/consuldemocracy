class Shared::AvatarComponent < ApplicationComponent
  attr_reader :record, :given_options
  delegate :avatar_image, to: :helpers

  def initialize(record, **given_options)
    @record = record
    @given_options = given_options
  end

  private

    def default_options
      { background_color: colors[seed % colors.size] }
    end

    def options
      default_options.merge(given_options)
    end

    def colors
      ["#16836d", "#12826c", "#896f06", "#a06608", "#1e8549", "#1e8549", "#b35e14",
       "#c75000", "#207ab6", "#2779b0", "#de2f1b", "#c0392b", "#9b59b6", "#8e44ad",
       "#6c767f", "#34495e", "#2c3e50", "#66797a", "#697677", "#d82286", "#c93b8e",
       "#db310f", "#727755", "#8a6f3d", "#8a6f3d", "#a94136"]
    end

    def seed
      record.id
    end
end
