class Admin::Poll::Questions::Answers::VideosController < Admin::Poll::BaseController
  before_action :load_answer, only: [:index, :new, :create]
  before_action :load_video, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @video = ::Poll::Question::Answer::Video.new
  end

  def create
    @video = ::Poll::Question::Answer::Video.new(video_params)

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
      redirect_to admin_answer_videos_path(@video.answer_id),
               notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    notice = if @video.destroy
      t("flash.actions.destroy.poll_question_answer_video")
             else
      t("flash.actions.destroy.error")
             end
    redirect_to :back, notice: notice
  end

  private

    def video_params
      params.require(:poll_question_answer_video).permit(:title, :url, :answer_id)
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:answer_id])
    end

    def load_video
      @video = ::Poll::Question::Answer::Video.find(params[:id])
    end
end
