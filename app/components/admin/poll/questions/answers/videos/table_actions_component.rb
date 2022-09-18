class Admin::Poll::Questions::Answers::Videos::TableActionsComponent < ApplicationComponent
  attr_reader :video

  def initialize(video)
    @video = video
  end
end
