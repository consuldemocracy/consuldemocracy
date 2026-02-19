class Polls::GalleryComponent < ApplicationComponent
  attr_reader :option
  use_helpers :is_active_class

  def initialize(option)
    @option = option
  end

  def render?
    option.images.any?
  end
end
