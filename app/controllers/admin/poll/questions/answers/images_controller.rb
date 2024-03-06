class Admin::Poll::Questions::Answers::ImagesController < Admin::Poll::BaseController
  include ImageAttributes

  load_and_authorize_resource :answer, class: "::Poll::Question::Answer"
  load_and_authorize_resource only: [:destroy]

  def index
  end

  def new
  end

  def create
    @answer.attributes = images_params
    authorize! :update, @answer

    if @answer.save
      redirect_to admin_answer_images_path(@answer),
                  notice: t("flash.actions.create.poll_question_answer_image")
    else
      render :new
    end
  end

  def destroy
    @image.destroy!

    redirect_to admin_answer_images_path(@image.imageable),
                notice: t("flash.actions.destroy.poll_question_answer_image")
  end

  private

    def images_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      [:answer_id, images_attributes: image_attributes]
    end
end
