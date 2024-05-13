class Admin::Poll::Questions::Options::VideosController < Admin::Poll::BaseController
  load_and_authorize_resource :option, class: "::Poll::Question::Option"
  load_and_authorize_resource class: "::Poll::Question::Option::Video", through: :option

  def index
  end

  def new
  end

  def create
    if @video.save
      redirect_to admin_option_videos_path(@option),
                  notice: t("flash.actions.create.poll_question_option_video")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @video.update(video_params)
      redirect_to admin_option_videos_path(@option), notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    @video.destroy!
    notice = t("flash.actions.destroy.poll_question_option_video")
    redirect_to admin_option_videos_path(@option), notice: notice
  end

  private

    def video_params
      params.require(:poll_question_option_video).permit(allowed_params)
    end

    def allowed_params
      [:title, :url]
    end
end
