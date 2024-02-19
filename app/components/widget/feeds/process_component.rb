class Widget::Feeds::ProcessComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers
  attr_reader :process
  delegate :image_path_for, to: :helpers

  def initialize(process)
    @process = process
  end
end
