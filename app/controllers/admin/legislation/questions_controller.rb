class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :question, class: "Legislation::Question", through: :process

  def index
    @questions = @process.questions
  end

  def new
    @question.question_options.build
  end

  def create
    @question.author = current_user
    if @question.save
      notice = t('admin.legislation.questions.create.notice', link: legislation_process_question_path(@process, @question).html_safe)
      redirect_to admin_legislation_process_questions_path, notice: notice
    else
      flash.now[:error] = t('admin.legislation.questions.create.error')
      render :new
    end
  end

  def update
    if @question.update(question_params)
      notice = t('admin.legislation.questions.update.notice', link: legislation_process_question_path(@process, @question).html_safe)
      redirect_to edit_admin_legislation_process_question_path(@process, @question), notice: notice
    else
      flash.now[:error] = t('admin.legislation.questions.update.error')
      render :edit
    end
  end

  def destroy
    @question.destroy
    redirect_to admin_legislation_process_questions_path, notice: t('admin.legislation.questions.destroy.notice')
  end

  private

    def question_params
      params.require(:legislation_question).permit(
        :title,
        question_options_attributes: [:id, :value, :_destroy]
      )
    end
end
