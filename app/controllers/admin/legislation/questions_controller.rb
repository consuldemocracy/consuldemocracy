class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :question, class: "Legislation::Question", through: :process

  def index
    @questions = @process.questions
  end

  def create
    if @question.save
      redirect_to admin_legislation_process_questions_path
    else
      render :new
    end
  end

  def update
    if @question.update(question_params)
      redirect_to admin_legislation_process_questions_path
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    redirect_to admin_legislation_process_questions_path
  end

  private

    def question_params
      params.require(:legislation_question).permit(
        :title,
        question_options_attributes: [:id, :value, :_destroy]
      )
    end
end
