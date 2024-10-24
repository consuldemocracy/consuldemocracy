class Widget::Feeds::ProcessComponent < ApplicationComponent
  use_helpers :image_path_for
  attr_reader :process

  def initialize(process)
    @process = process
  end
end
