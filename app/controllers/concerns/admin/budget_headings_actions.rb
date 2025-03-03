module Admin::BudgetHeadingsActions
  extend ActiveSupport::Concern

  included do
    include Translatable
    include FeatureFlags
    feature_flag :budgets

    before_action :load_geozones, only: [:new, :create, :edit, :update]
    before_action :load_budget
    before_action :load_group
    before_action :load_heading, only: [:edit, :update, :destroy]
  end

  def edit
  end

  def create
    @heading = @group.headings.new(budget_heading_params)
    if @heading.save
      redirect_to headings_index, notice: t("admin.budget_headings.create.notice")
    else
      render new_action
    end
  end

  def update
  sanitized_params = budget_heading_params
  sanitized_params[:geozone_ids] = sanitized_params[:geozone_ids].reject(&:blank?) if sanitized_params[:geozone_ids].present?

  if @heading.update(sanitized_params)
    Rails.logger.info("Budget heading updated successfully. Parameters: #{sanitized_params.inspect}")
    redirect_to headings_index, notice: t("admin.budget_headings.update.notice")
  else
    puts sanitized_params.inspect
    render :edit
  end
end


  def old_update
    if @heading.update(budget_heading_params)
      Rails.logger.info("Budget heading updated successfully. Parameters: #{budget_heading_params.inspect}")
      redirect_to headings_index, notice: t("admin.budget_headings.update.notice")
    else
      puts budget_heading_params.inspect
      render :edit
      
    end
  end

  def destroy
    if @heading.can_be_deleted?
      @heading.destroy!
      redirect_to headings_index, notice: t("admin.budget_headings.destroy.success_notice")
    else
      redirect_to headings_index, alert: t("admin.budget_headings.destroy.unable_notice")
    end
  end

  private

    def load_geozones
      @geozones = Geozone.order(:name)
      Rails.logger.debug("Loaded Geozones: #{@geozones.inspect}")
    end
    
    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:group_id]
    end

    def load_heading
      @heading = @group.headings.find_by_slug_or_id! params[:id]
    end

    def budget_heading_params
      params.require(:budget_heading).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude,
                          :max_ballot_lines, :geozone_id, :geozone_restricted, geozone_ids: [] ]

      [*valid_attributes, translation_params(Budget::Heading)]
    end
end
