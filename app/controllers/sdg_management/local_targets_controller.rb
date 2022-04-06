class SDGManagement::LocalTargetsController < SDGManagement::BaseController
  include Translatable

  load_and_authorize_resource class: "SDG::LocalTarget"

  def index
    @local_targets = @local_targets.sort
  end

  def new
  end

  def create
    if @local_target.save
      redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @local_target.update(local_target_params)
      redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @local_target.destroy!
    redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.destroy.notice")
  end

  private

    def local_target_params
      translations_attributes = translation_params(::SDG::LocalTarget)
      params.require(:sdg_local_target).permit(:code, :target_id, translations_attributes)
    end
end
