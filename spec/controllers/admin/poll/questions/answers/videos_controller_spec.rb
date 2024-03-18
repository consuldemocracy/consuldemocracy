require "rails_helper"

describe Admin::Poll::Questions::Answers::VideosController, :admin do
  let(:current_answer) { create(:poll_question_answer, poll: create(:poll)) }
  let(:future_answer) { create(:poll_question_answer, poll: create(:poll, :future)) }

  describe "POST create" do
    it "is not possible for an already started poll" do
      post :create, params: {
        poll_question_answer_video: {
          title: "Video from started poll",
          url: "https://www.youtube.com/watch?v=-JMf43st-1A"
        },
        answer_id: current_answer
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'create' on Video."
      expect(Poll::Question::Answer::Video.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: {
        poll_question_answer_video: {
          title: "Video from not started poll",
          url: "https://www.youtube.com/watch?v=-JMf43st-1A"
        },
        answer_id: future_answer
      }

      expect(response).to redirect_to admin_answer_videos_path(future_answer)
      expect(flash[:notice]).to eq "Video created successfully"
      expect(Poll::Question::Answer::Video.count).to eq 1
    end
  end

  describe "PATCH update" do
    it "is not possible for an already started poll" do
      current_video = create(:poll_answer_video, answer: current_answer, title: "Sample title")

      patch :update, params: {
        poll_question_answer_video: {
          title: "New title"
        },
        id: current_video,
        answer_id: current_answer
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Video."
      expect(current_video.reload.title).to eq "Sample title"
    end

    it "is possible for a not started poll" do
      future_video = create(:poll_answer_video, answer: future_answer)

      patch :update, params: {
        poll_question_answer_video: {
          title: "New title"
        },
        id: future_video,
        answer_id: future_answer
      }

      expect(response).to redirect_to admin_answer_videos_path(future_answer)
      expect(flash[:notice]).to eq "Changes saved"
      expect(future_video.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_video = create(:poll_answer_video, answer: current_answer)
      delete :destroy, params: { answer_id: current_answer, id: current_video }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Video."
      expect(Poll::Question::Answer::Video.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_video = create(:poll_answer_video, answer: future_answer)
      delete :destroy, params: { answer_id: future_answer, id: future_video }

      expect(response).to redirect_to admin_answer_videos_path(future_answer)
      expect(flash[:notice]).to eq "Answer video deleted successfully."
      expect(Poll::Question::Answer::Video.count).to eq 0
    end
  end
end
