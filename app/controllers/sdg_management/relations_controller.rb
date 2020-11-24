class SDGManagement::RelationsController < SDGManagement::BaseController
  def index
    @records = relatable_class.accessible_by(current_ability).order(:id).page(params[:page])
  end

  def edit
    @record = relatable_class.find(params[:id])
  end

  private

    def relatable_class
      params[:relatable_type].classify.constantize
    end
end
