class SDGManagement::RelationsController < SDGManagement::BaseController
  before_action :check_feature_flags
  before_action :load_record, only: [:edit, :update]

  def index
    @records = relatable_class
               .accessible_by(current_ability)
               .by_goal(params[:goal_code])
               .order(:id)
               .page(params[:page])

    @records = @records.search(params[:search]) if params[:search].present?
  end

  def edit
  end

  def update
    @record.sdg_target_list = params[@record.class.table_name.singularize][:sdg_target_list]

    redirect_to action: :index
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
end
