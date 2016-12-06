class Admin::Legislation::ProcessesController < Admin::Legislation::BaseController
  has_filters %w{open next past all}, only: :index

  load_and_authorize_resource :process, class: "Legislation::Process"

  def index
    @processes = ::Legislation::Process.send(@current_filter).page(params[:page])
  end

  def create
    @process = ::Legislation::Process.new(process_params)
    if @process.save
      redirect_to admin_legislation_processes_path
    else
      render :new
    end
  end

  def update
    @process.assign_attributes(process_params)
    if @process.update(process_params)
      redirect_to admin_legislation_processes_path
    else
      render :edit
    end
  end

  def destroy
    @process.destroy
    redirect_to admin_legislation_processes_path
  end

  private

    def process_params
      params.require(:legislation_process).permit(
        :title,
        :description_summary,
        :target_summary,
        :description,
        :target,
        :how_to_participate,
        :additional_info,
        :start_date,
        :end_date,
        :debate_start_date,
        :debate_end_date,
        :draft_publication_date,
        :allegations_start_date,
        :allegations_end_date,
        :final_publication_date
      )
    end
end
