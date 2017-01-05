class Admin::Legislation::DraftVersionsController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :draft_version, class: "Legislation::DraftVersion", through: :process

  def index
    @draft_versions = @process.draft_versions
  end

  def create
    if @draft_version.save
      redirect_to admin_legislation_process_draft_versions_path, notice: t('admin.legislation.draft_versions.create.notice', link: legislation_process_draft_version_path(@process, @draft_version).html_safe)
    else
      flash.now[:error] = t('admin.legislation.draft_versions.create.error')
      render :new
    end
  end

  def update
    if @draft_version.update(draft_version_params)
      redirect_to edit_admin_legislation_process_draft_version_path(@process, @draft_version), notice: t('admin.legislation.draft_versions.update.notice', link: legislation_process_draft_version_path(@process, @draft_version).html_safe)
    else
      flash.now[:error] = t('admin.legislation.draft_versions.update.error')
      render :edit
    end
  end

  def destroy
    @draft_version.destroy
    redirect_to admin_legislation_process_draft_versions_path, notice: t('admin.legislation.draft_versions.destroy.notice')
  end

  private

    def draft_version_params
      params.require(:legislation_draft_version).permit(
        :title,
        :changelog,
        :status,
        :final_version,
        :body,
        :body_html
      )
    end
end
