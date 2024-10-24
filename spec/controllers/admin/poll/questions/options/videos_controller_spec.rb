require "rails_helper"

describe Admin::Poll::Questions::Options::VideosController, :admin do
  let(:current_option) { create(:poll_question_option, poll: create(:poll)) }
  let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }

  describe "POST create" do
    it "is not possible for an already started poll" do
      post :create, params: {
        poll_question_option_video: {
          title: "Video from started poll",
          url: "https://www.youtube.com/watch?v=-JMf43st-1A"
        },
        option_id: current_option
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'create' on Video."
      expect(Poll::Question::Option::Video.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: {
        poll_question_option_video: {
          title: "Video from not started poll",
          url: "https://www.youtube.com/watch?v=-JMf43st-1A"
        },
        option_id: future_option
      }

      expect(response).to redirect_to admin_option_videos_path(future_option)
      expect(flash[:notice]).to eq "Video created successfully"
      expect(Poll::Question::Option::Video.count).to eq 1
    end
  end

  describe "PATCH update" do
    it "is not possible for an already started poll" do
      current_video = create(:poll_option_video, option: current_option, title: "Sample title")

      patch :update, params: {
        poll_question_option_video: {
          title: "New title"
        },
        id: current_video,
        option_id: current_option
      }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Video."
      expect(current_video.reload.title).to eq "Sample title"
    end

    it "is possible for a not started poll" do
      future_video = create(:poll_option_video, option: future_option)

      patch :update, params: {
        poll_question_option_video: {
          title: "New title"
        },
        id: future_video,
        option_id: future_option
      }

      expect(response).to redirect_to admin_option_videos_path(future_option)
      expect(flash[:notice]).to eq "Changes saved"
      expect(future_video.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_video = create(:poll_option_video, option: current_option)
      delete :destroy, params: { option_id: current_option, id: current_video }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Video."
      expect(Poll::Question::Option::Video.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_video = create(:poll_option_video, option: future_option)
      delete :destroy, params: { option_id: future_option, id: future_video }

      expect(response).to redirect_to admin_option_videos_path(future_option)
      expect(flash[:notice]).to eq "Answer video deleted successfully."
      expect(Poll::Question::Option::Video.count).to eq 0
    end
  end
end
