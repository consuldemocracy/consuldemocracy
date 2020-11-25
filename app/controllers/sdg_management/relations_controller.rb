class SDGManagement::RelationsController < SDGManagement::BaseController
  before_action :load_record, only: [:edit, :update]

  def index
    @records = relatable_class.accessible_by(current_ability).order(:id).page(params[:page])
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
end
