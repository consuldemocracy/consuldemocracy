class Admin::Poll::Questions::OptionsController < Admin::Poll::BaseController
  include Translatable

  load_and_authorize_resource :question, class: "::Poll::Question"
  load_and_authorize_resource class: "::Poll::Question::Option",
                              through: :question,
                              through_association: :question_options

  def new
  end

  def create
    if @option.save
      redirect_to admin_question_path(@question),
                  notice: t("flash.actions.create.poll_question_option")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @option.update(option_params)
      redirect_to admin_question_path(@question),
                  notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    @option.destroy!
    redirect_to admin_question_path(@question), notice: t("admin.answers.destroy.success_notice")
  end

  def order_options
    ::Poll::Question::Option.order_options(params[:ordered_list])
    head :ok
  end

  private

    def option_params
      params.require(:poll_question_option).permit(allowed_params)
    end

    def allowed_params
      attributes = [:title, :description, :given_order]

      [*attributes, translation_params(Poll::Question::Option)]
    end
end
