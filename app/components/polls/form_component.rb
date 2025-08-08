class Polls::FormComponent < ApplicationComponent
  attr_reader :web_vote
  use_helpers :cannot?, :current_user
  delegate :poll, :questions, to: :web_vote

  def initialize(web_vote)
    @web_vote = web_vote
  end

  private

    def form_attributes
      { url: answer_poll_path(poll), method: :post, html: { class: "poll-form" }}
    end

    def disabled?
      cannot?(:answer, poll) || poll.voted_in_booth?(current_user)
    end
end
