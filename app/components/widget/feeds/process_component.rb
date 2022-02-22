class Widget::Feeds::ProcessComponent < ApplicationComponent
  attr_reader :process
  delegate :image_path_for, to: :helpers

  def initialize(process)
    @process = process
  end
end
