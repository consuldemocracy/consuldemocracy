class Admin::Poll::Questions::Options::Videos::TableActionsComponent < ApplicationComponent
  attr_reader :video

  def initialize(video)
    @video = video
  end
end
