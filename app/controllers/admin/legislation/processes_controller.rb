class Admin::Legislation::ProcessesController < Admin::Legislation::BaseController
  has_filters %w{open next past all}, only: :index

  load_and_authorize_resource :process, class: "Legislation::Process"

  def index
    @processes = ::Legislation::Process.send(@current_filter).order('id DESC').page(params[:page])
  end

  def create
    if @process.save
      redirect_to edit_admin_legislation_process_path(@process), notice: t('admin.legislation.processes.create.notice', link: legislation_process_path(@process).html_safe)
    else
      flash.now[:error] = t('admin.legislation.processes.create.error')
      render :new
    end
  end

  def update
    if @process.update(process_params)
      redirect_to edit_admin_legislation_process_path(@process), notice: t('admin.legislation.processes.update.notice', link: legislation_process_path(@process).html_safe)
    else
      flash.now[:error] = t('admin.legislation.processes.update.error')
      render :edit
    end
  end

  def destroy
    @process.destroy
    redirect_to admin_legislation_processes_path, notice: t('admin.legislation.processes.destroy.notice')
  end

  private

    def process_params
      params.require(:legislation_process).permit(
        :title,
        :summary,
        :description,
        :additional_info,
        :start_date,
        :end_date,
        :debate_start_date,
        :debate_end_date,
        :draft_publication_date,
        :allegations_start_date,
        :allegations_end_date,
        :result_publication_date,
        :debate_phase_enabled,
        :allegations_phase_enabled,
        :draft_publication_enabled,
        :result_publication_enabled
      )
    end
end
