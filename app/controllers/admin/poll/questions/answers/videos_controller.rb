class Admin::Poll::Questions::Answers::VideosController < Admin::Poll::BaseController
  load_resource :answer, class: "::Poll::Question::Answer"
  load_resource class: "::Poll::Question::Answer::Video", through: :answer

  def index
  end

  def new
  end

  def create
    if @video.save
      redirect_to admin_answer_videos_path(@answer),
               notice: t("flash.actions.create.poll_question_answer_video")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @video.update(video_params)
      redirect_to admin_answer_videos_path(@answer), notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    @video.destroy!
    notice = t("flash.actions.destroy.poll_question_answer_video")
    redirect_to admin_answer_videos_path(@answer), notice: notice
  end

  private

    def video_params
      params.require(:poll_question_answer_video).permit(allowed_params)
    end

    def allowed_params
      [:title, :url]
    end
end
