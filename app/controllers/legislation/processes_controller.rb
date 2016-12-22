class Legislation::ProcessesController < Legislation::BaseController
  has_filters %w{open next past}, only: :index
  load_and_authorize_resource

  def index
    @current_filter ||= 'open'
    @processes = ::Legislation::Process.send(@current_filter).page(params[:page])
  end

  def show
  end

  def draft_publication
    phase :draft_publication
  end

  def allegations
    phase :allegations
  end

  def final_version_publication
    phase :final_version_publication
  end

  private

    def phase(phase)
      @process = ::Legislation::Process.find(params[:process_id])
      @phase = phase
      render :phase
    end
end
