class Debates::MarkFeaturedActionComponent < ApplicationComponent
  attr_reader :debate

  def initialize(debate)
    @debate = debate
  end

  def render?
    can? :mark_featured, debate
  end
end
