require "rails_helper"

describe Admin::Poll::Questions::FormComponent do
  before { sign_in(create(:administrator).user) }

  context "question with a poll" do
    let(:poll) { create(:poll) }
    let(:question) { Poll::Question.new(poll: poll) }

    it "does not display the poll selector" do
      render_inline Admin::Poll::Questions::FormComponent.new(question, url: "/")

      expect(page).not_to have_select "Poll"
      expect(page).to have_field "poll_question[poll_id]", type: :hidden, with: poll.id
    end
  end

  context "question without a poll" do
    let(:question) { Poll::Question.new }

    it "allows selecting polls which have not already started" do
      create(:poll, :future, name: "Future poll")

      render_inline Admin::Poll::Questions::FormComponent.new(question, url: "/")

      expect(page).to have_select "Poll", options: ["Select Poll", "Future poll"]
    end

    it "does not allow selecting polls which have already started" do
      create(:poll, name: "Already started poll")

      render_inline Admin::Poll::Questions::FormComponent.new(question, url: "/")

      expect(page).to have_select "Poll", options: ["Select Poll"]
    end
  end
end
