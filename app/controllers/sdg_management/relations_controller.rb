class SDGManagement::RelationsController < SDGManagement::BaseController
  before_action :check_feature_flags
  before_action :load_record, only: [:edit, :update]

  FILTERS = %w[pending_sdg_review all sdg_reviewed].freeze
  has_filters FILTERS, only: :index

  def index
    @records = relatable_class
               .send(@current_filter)
               .accessible_by(current_ability)
               .by_goal(params[:goal_code])
               .by_target(params[:target_code])
               .order(:id)
               .page(params[:page])

    @records = @records.search(params[:search]) if params[:search].present?
  end

  def edit
  end

  def update
    @record.related_sdg_list = params[@record.class.table_name.singularize][:related_sdg_list]

    redirect_to({ action: :index }, notice: update_notice)
  end

  private

    def load_record
      @record = relatable_class.find(params[:id])
    end

    def relatable_class
      params[:relatable_type].classify.constantize
    end

    def check_feature_flags
      process_name = params[:relatable_type].split("/").first
      process_name = process_name.pluralize unless process_name == "legislation"

      check_feature_flag(process_name)
      raise FeatureDisabled, process_name unless Setting["sdg.process.#{process_name}"]
    end

    def update_notice
      if @record.sdg_review.present?
        t("sdg_management.relations.update.notice", relatable: relatable_class.model_name.human)
      else
        @record.create_sdg_review!
        t("sdg_management.relations.update_and_review.notice", relatable: relatable_class.model_name.human)
      end
    end
end
