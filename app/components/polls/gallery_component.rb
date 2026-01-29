class Polls::GalleryComponent < ApplicationComponent
  attr_reader :option
  delegate :is_active_class, to: :helpers

  def initialize(option)
    @option = option
  end

  def render?
    option.images.any?
  end
end
