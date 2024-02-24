class Debates::NewComponent < ApplicationComponent
  include Header
  attr_reader :debate
  delegate :new_window_link_to, to: :helpers

  def initialize(debate)
    @debate = debate
  end

  def title
    t("debates.new.start_new")
  end
end
