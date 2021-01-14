class Widget::Feeds::DebateComponent < ApplicationComponent
  attr_reader :debate

  def initialize(debate)
    @debate = debate
  end
end
