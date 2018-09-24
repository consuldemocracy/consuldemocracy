class Admin::Legislation::DraftVersionsController < Admin::Legislation::BaseController
  include Translatable

  load_and_authorize_resource :draft_version, class: "Legislation::DraftVersion", through: :process, prepend: true
  load_and_authorize_resource :process, class: "Legislation::Process", prepend: true

  def index
    @draft_versions = @process.draft_versions
  end

  def create
    if @draft_version.save
      link = legislation_process_draft_version_path(@process, @draft_version).html_safe
      notice = t('admin.legislation.draft_versions.create.notice', link: link)
      redirect_to admin_legislation_process_draft_versions_path, notice: notice
    else
      flash.now[:error] = t('admin.legislation.draft_versions.create.error')
      render :new
    end
  end

  def update
    if @draft_version.update(draft_version_params)
      link = legislation_process_draft_version_path(@process, @draft_version).html_safe
      notice = t('admin.legislation.draft_versions.update.notice', link: link)
      edit_path = edit_admin_legislation_process_draft_version_path(@process, @draft_version)
      redirect_to edit_path, notice: notice
    else
      flash.now[:error] = t('admin.legislation.draft_versions.update.error')
      render :edit
    end
  end

  def destroy
    @draft_version.destroy
    notice = t('admin.legislation.draft_versions.destroy.notice')
    redirect_to admin_legislation_process_draft_versions_path, notice: notice
  end

  private

    def draft_version_params
      params.require(:legislation_draft_version).permit(
        :title,
        :changelog,
        :status,
        :final_version,
        :body,
        :body_html,
        *translation_params(Legislation::DraftVersion)
      )
    end

    def resource
      @draft_version
    end
end
