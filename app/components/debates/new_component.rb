class Debates::NewComponent < ApplicationComponent
  include Header
  attr_reader :debate
  use_helpers :new_window_link_to

  def initialize(debate)
    @debate = debate
  end

  def title
    t("debates.new.start_new")
  end
end
