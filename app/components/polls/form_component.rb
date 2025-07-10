class Polls::FormComponent < ApplicationComponent
  attr_reader :web_vote
  delegate :poll, :questions, to: :web_vote

  def initialize(web_vote)
    @web_vote = web_vote
  end

  private

    def form_attributes
      { url: answer_poll_path(poll), method: :post, html: { class: "poll-form" }}
    end
end
