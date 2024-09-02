class Widget::Feeds::ProcessComponent < ApplicationComponent
  use_helpers :image_path_for
  attr_reader :process
  delegate :image_path_for, to: :helpers

  def initialize(process)
    @process = process
  end
end
