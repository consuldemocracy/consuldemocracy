require "rails_helper"

describe Admin::Poll::Questions::OptionsController, :admin do
  let(:current_question) { create(:poll_question, poll: create(:poll)) }
  let(:future_question) { create(:poll_question, poll: create(:poll, :future)) }

  describe "POST create" do
    it "is not possible for an already started poll" do
      post :create, params: {
        poll_question_option: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "Answer from started poll"
            }
          }
        },
        question_id: current_question
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'create' on Option."
      expect(Poll::Question::Option.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: {
        poll_question_option: {
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
      expect(Poll::Question::Option.last.title).to eq "Answer from future poll"
      expect(Poll::Question::Option.count).to eq 1
    end
  end

  describe "PATCH update" do
    it "is not possible for an already started poll" do
      current_option = create(:poll_question_option, question: current_question, title: "Sample title")

      patch :update, params: {
        poll_question_option: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: current_option.translations.first.id
            }
          }
        },
        question_id: current_question,
        id: current_option
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Option."
      expect(current_option.reload.title).to eq "Sample title"
    end

    it "is possible for a not started poll" do
      future_option = create(:poll_question_option, question: future_question)

      patch :update, params: {
        poll_question_option: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "New title",
              id: future_option.translations.first.id
            }
          }
        },
        question_id: future_question,
        id: future_option
      }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(flash[:notice]).to eq "Changes saved"
      expect(future_option.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_option = create(:poll_question_option, question: current_question)
      delete :destroy, params: { question_id: current_question, id: current_option }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Option."
      expect(Poll::Question::Option.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_option = create(:poll_question_option, question: future_question)
      delete :destroy, params: { question_id: future_question, id: future_option }

      expect(response).to redirect_to admin_question_path(future_question)
      expect(flash[:notice]).to eq "Answer deleted successfully"
      expect(Poll::Question::Option.count).to eq 0
    end
  end
end
