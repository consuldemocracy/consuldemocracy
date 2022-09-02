class Admin::Poll::Questions::Answers::Videos::TableActionsComponent < ApplicationComponent
  attr_reader :video
  delegate :can?, to: :helpers

  def initialize(video)
    @video = video
  end

  private

    def actions
      [:edit, :destroy].select { |action| can?(action, video) }
    end
end
