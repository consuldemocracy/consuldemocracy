class Widget::Feeds::ProcessComponent < ApplicationComponent
  attr_reader :process

  def initialize(process)
    @process = process
  end
end
