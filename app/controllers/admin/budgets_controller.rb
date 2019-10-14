class Admin::BudgetsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{current finished}, only: :index

  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @budget = Budget.includes(groups: :headings).find(params[:id])
  end

  def new
  end

  def edit
  end


  def annotate_participants
    @total_ballots_count = @budget.ballots.where.not(user_id: nil).joins(:user).where('users.verified_at IS NOT NULL').count
    @total_ballots_annotated = @budget.not_sent_participant_count || 0
    @budget.update(not_sent_participant_count: [@total_ballots_count, @total_ballots_annotated].max)
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).calculate_winners }
    redirect_to admin_budget_path(@budget), notice: "Resultados calculados"
  end

  #GET-112
  def results
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    else
      @group = @budget.groups.first if @budget.groups.any?
    end

    @confirmations = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil, group_id: @group.id)
                         .where.not(confirmed_at: nil)
                         .joins(:ballot)
                         .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                         .uniq('budget_ballot_confirmations.id')

  end

  def public_results
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    else
      @group = @budget.groups.first if @budget.groups.any?
    end
  end

  #GET-130
  def ballot_dashboard

    # Todas las papeletas de usuarios correctos
    @ballots = @budget.ballots.where.not(user_id: nil).joins(:user).where('users.verified_at IS NOT NULL').order('created_at desc')

    # Todas las confirmaciones creadas (se le dió al SMS)
    @confirmations = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil)

    confirmations_ids = @confirmations.pluck(:ballot_id)

    # Todas las confirmaciones pendientes de confirmación (validar SMS)
    @confirmations_sms_pending = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil).where(confirmed_at: nil)

    # Papeletas de usuarios correctos que no se correspondan con  confirmaciones que no están verificadas
    @ballots_uncompleted = @ballots.where.not(id: confirmations_ids )

    # No descartadas | Que están confirmadas (TOTAL)
    @confirmations_verified = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil).where.not(confirmed_at: nil)

    # No descartadas | que NO tienen código SMS | Que están confirmadas
    @confirmations_verified_by_manager = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil, sms_code_sent_at: nil).where.not(confirmed_at: nil)

    # No descartadas | que tienen código SMS | Que están confirmadas
    @confirmations_verified_by_sms = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil).where.not(sms_code_sent_at: nil).where.not(confirmed_at: nil)
  end

  #GET-112
  def ballot_paper
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    else
      @group = @budget.groups.first if @budget.groups.any?
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.update.notice')
    else
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.create.notice')
    else
      render :new
    end
  end

  private

    def budget_params
      descriptions = Budget::PHASES.map{|p| "description_#{p}"}.map(&:to_sym)
      valid_attributes = [:name, :phase, :currency_symbol] + descriptions
      params.require(:budget).permit(*valid_attributes)
    end

end
