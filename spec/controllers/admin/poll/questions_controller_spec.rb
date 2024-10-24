require "rails_helper"

describe Admin::Poll::QuestionsController, :admin do
  let(:current_poll) { create(:poll) }
  let(:future_poll) { create(:poll, :future) }

  describe "POST create" do
    it "is not possible for an already started poll" do
      post :create, params: {
        poll_question: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "Question from started poll"
            }
          },
          poll_id: current_poll
        }
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'create' on Question."
      expect(Poll::Question.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: {
        poll_question: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "Question from future poll"
            }
          },
          poll_id: future_poll
        }
      }

      expect(response).to redirect_to admin_question_path(Poll::Question.last)
      expect(Poll::Question.last.title).to eq "Question from future poll"
      expect(Poll::Question.count).to eq 1
    end
  end

  describe "PATCH update" do
    it "is not possible for an already started poll" do
      current_question = create(:poll_question, poll: current_poll, title: "Sample title")

      patch :update, params: {
        poll_question: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: current_question.translations.first.id
            }
          }
        },
        id: current_question
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Question."
      expect(current_question.reload.title).to eq "Sample title"
    end

    it "is possible for a not started poll" do
      future_question = create(:poll_question, poll: future_poll)

      patch :update, params: {
        poll_question: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: future_question.translations.first.id
            }
          }
        },
        id: future_question
      }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(flash[:notice]).to eq "Changes saved"
      expect(future_question.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_question = create(:poll_question, poll: current_poll)
      delete :destroy, params: { id: current_question }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Question."
      expect(Poll::Question.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_question = create(:poll_question, poll: future_poll)
      delete :destroy, params: { id: future_question }

      expect(response).to redirect_to admin_poll_path(future_poll)
      expect(flash[:notice]).to eq "Question deleted successfully"
      expect(Poll::Question.count).to eq 0
    end
  end
end
