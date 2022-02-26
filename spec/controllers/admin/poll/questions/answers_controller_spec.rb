require "rails_helper"

describe Admin::Poll::Questions::AnswersController, :admin do
  let(:current_question) { create(:poll_question, poll: create(:poll)) }
  let(:future_question) { create(:poll_question, poll: create(:poll, :future)) }

  describe "POST create" do
    it "is not possible for an already started poll" do
      post :create, params: {
        poll_question_answer: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "Answer from started poll"
            }
          }
        },
        question_id: current_question
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'create' on Answer."
      expect(Poll::Question::Answer.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: {
        poll_question_answer: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "Answer from future poll"
            }
          }
        },
        question_id: future_question
      }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(Poll::Question::Answer.last.title).to eq "Answer from future poll"
      expect(Poll::Question::Answer.count).to eq 1
    end
  end

  describe "PATCH update" do
    it "is not possible for an already started poll" do
      current_answer = create(:poll_question_answer, question: current_question, title: "Sample title")

      patch :update, params: {
        poll_question_answer: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: current_answer.translations.first.id
            }
          }
        },
        question_id: current_question,
        id: current_answer
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Answer."
      expect(current_answer.reload.title).to eq "Sample title"
    end

    it "is possible for a not started poll" do
      future_answer = create(:poll_question_answer, question: future_question)

      patch :update, params: {
        poll_question_answer: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: future_answer.translations.first.id
            }
          }
        },
        question_id: future_question,
        id: future_answer
      }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(flash[:notice]).to eq "Changes saved"
      expect(future_answer.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_answer = create(:poll_question_answer, question: current_question)
      delete :destroy, params: { question_id: current_question, id: current_answer }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Answer."
      expect(Poll::Question::Answer.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_answer = create(:poll_question_answer, question: future_question)
      delete :destroy, params: { question_id: future_question, id: future_answer }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(flash[:notice]).to eq "Answer deleted successfully"
      expect(Poll::Question::Answer.count).to eq 0
    end
  end
end
