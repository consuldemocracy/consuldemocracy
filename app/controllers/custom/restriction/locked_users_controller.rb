class Restriction::LockedUsersController < Restriction::BaseController
  def index
    @locked_user = Budget::LockedUser.new
  end

  def create
    if @locked_user = Budget::LockedUser.create!(locked_user_params)
      redirect_to restriction_locked_user_path(@locked_user), notice: t("restriction.locked_users.create.notice")
    else
      flash.now[:error] = t("restriction.locked_users.create.error")
      render :preview
    end
  end

  def show
    @locked_user = Budget::LockedUser.find(params[:id])
  end

  def preview
    params[:budget_locked_user][:document_number].upcase
    @locked_user = Budget::LockedUser.new(locked_user_params)
    old_locked_user = Budget::LockedUser.find_by(
      budget_id: locked_user_params[:budget_id],
      document_type: locked_user_params[:document_type],
      document_number: locked_user_params[:document_number])
    @already_locked = old_locked_user.present?

    if @already_locked
      @in_census = true
      @locked_time = old_locked_user.created_at
    elsif @locked_user.valid?
      document_verification = Verification::Management::Document.new(document_verification_params)
      if document_verification.valid?
        @in_census = false
        if document_verification.in_census?
          @in_census = true
        end
        @has_voted = false
        if document_verification.user?
          @has_voted = Budget::Ballot::Line.joins(:ballot).where(budget_ballots: {
            user_id: document_verification.user,
            budget_id: locked_user_params[:budget_id]
          }).exists?
        end
      end
    else
      render :index
    end
  end

  private

    def document_verification_params
      params.require(:budget_locked_user).except(:budget_id).permit(:document_type, :document_number)
    end

    def locked_user_params
      params.require(:budget_locked_user).permit(
        :document_type, :document_number, :budget_id
      )
    end
end
