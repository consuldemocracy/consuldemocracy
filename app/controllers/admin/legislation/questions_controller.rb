class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  include Translatable

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
      notice = t('admin.legislation.questions.create.notice', link: question_path)
      redirect_to admin_legislation_process_questions_path, notice: notice
    else
      flash.now[:error] = t('admin.legislation.questions.create.error')
      render :new
    end
  end

  def update
    if @question.update(question_params)
      notice = t('admin.legislation.questions.update.notice', link: question_path)
      redirect_to edit_admin_legislation_process_question_path(@process, @question), notice: notice
    else
      flash.now[:error] = t('admin.legislation.questions.update.error')
      render :edit
    end
  end

  def destroy
    @question.destroy
    notice = t('admin.legislation.questions.destroy.notice')
    redirect_to admin_legislation_process_questions_path, notice: notice
  end

  private

    def question_path
      legislation_process_question_path(@process, @question).html_safe
    end

    def question_params
      params.require(:legislation_question).permit(
        :title,
        *translation_params(::Legislation::Question),
        question_options_attributes: [:id, :value,
                                      *translation_params(::Legislation::QuestionOption)]
      )
    end

    def resource
      @question || ::Legislation::Question.find(params[:id])
    end
end
