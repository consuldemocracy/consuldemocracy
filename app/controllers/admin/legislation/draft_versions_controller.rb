class Admin::Legislation::DraftVersionsController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :draft_version, class: "Legislation::DraftVersion", through: :process

  def index
    @draft_versions = @process.draft_versions
  end

  def create
    @draft_version = @process.draft_versions.new(draft_version_params)
    if @process.save
      redirect_to admin_legislation_process_draft_versions_path
    else
      render :new
    end
  end

  def update
    if @draft_version.update(draft_version_params)
      redirect_to admin_legislation_process_draft_versions_path
    else
      render :edit
    end
  end

  def destroy
    @draft_version.destroy
    redirect_to admin_legislation_process_draft_versions_path
  end

  private

    def draft_version_params
      params.require(:legislation_draft_version).permit(
        :legislation_process_id,
        :title,
        :changelog,
        :status,
        :final_version,
        :body
      )
    end
end
