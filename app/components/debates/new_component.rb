class Debates::NewComponent < ApplicationComponent
  attr_reader :debate

  def initialize(debate)
    @debate = debate
  end
end
