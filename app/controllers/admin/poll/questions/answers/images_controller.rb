class Admin::Poll::Questions::Answers::ImagesController < Admin::Poll::BaseController
  before_action :load_answer, except: :destroy

  def index
  end

  def new
    @answer = ::Poll::Question::Answer.find(params[:answer_id])
  end

  def create
    @answer = ::Poll::Question::Answer.find(params[:answer_id])
    @answer.attributes = images_params

    if @answer.save
      redirect_to admin_answer_images_path(@answer),
               notice: t("flash.actions.create.poll_question_answer_image")
    else
      render :new
    end
  end

  def destroy
    @image = ::Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private

    def images_params
      params.require(:poll_question_answer).permit(:answer_id,
        images_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy])
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:answer_id])
    end
end
