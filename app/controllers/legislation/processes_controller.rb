class Legislation::ProcessesController < Legislation::BaseController
  include RandomSeed
  include DownloadSettingsHelper

  has_filters %w[open past], only: :index
  has_filters %w[random winners], only: :proposals

  load_and_authorize_resource

  before_action :set_random_seed, only: :proposals
  before_action :check_past, only: :resume


  def index
    @current_filter ||= "open"
    @processes = ::Legislation::Process.send(@current_filter).published
                 .not_in_draft.order(start_date: :desc).page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(process_for_download, Legislation::Process),
                             type: "text/csv",
                             disposition: "attachment",
                             filename: "legislation_processes.csv" }
    end
  end

  def show
    draft_version = @process.draft_versions.published.last
    allegations_phase = @process.allegations_phase

    if @process.homepage_enabled? && @process.homepage.present?
      render :show
    elsif allegations_phase.enabled? && allegations_phase.started? && draft_version.present?
      redirect_to legislation_process_draft_version_path(@process, draft_version)
    elsif @process.debate_phase.enabled?
      redirect_to debate_legislation_process_path(@process)
    elsif @process.proposals_phase.enabled?
      redirect_to proposals_legislation_process_path(@process)
    else
      redirect_to allegations_legislation_process_path(@process)
    end
  end

  def debate
    set_process
    @phase = :debate_phase

    if @process.debate_phase.started? || (current_user && current_user.administrator?)
      render :debate
    else
      render :phase_not_open
    end
  end

  def draft_publication
    set_process
    @phase = :draft_publication

    if @process.draft_publication.started?
      draft_version = @process.draft_versions.published.last

      if draft_version.present?
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def allegations
    set_process
    @phase = :allegations_phase

    if @process.allegations_phase.started?
      draft_version = @process.draft_versions.published.last

      if draft_version.present?
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def result_publication
    set_process
    @phase = :result_publication

    if @process.result_publication.started?
      final_version = @process.final_draft_version

      if final_version.present?
        redirect_to legislation_process_draft_version_path(@process, final_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def milestones
    @phase = :milestones
  end

  def resume
    @phase = :resume
    respond_to do |format|
      format.html
      format.xlsx {render xlsx: "resume_to_xlsx", filename: ("resume-" + Date.today.to_s + ".xlsx")}
    end
  end

  def check_past
    set_process
    if !@process.past?
      redirect_to legislation_process_path
    end
  end

  def proposals
    set_process
    @phase = :proposals_phase

    @proposals = ::Legislation::Proposal.where(process: @process)
    @proposals = @proposals.search(params[:search]) if params[:search].present?

    @current_filter = "winners" if params[:filter].blank? && @proposals.winners.any?

    if @current_filter == "random"
      @proposals = @proposals.sort_by_random(session[:random_seed]).page(params[:page])
    else
      @proposals = @proposals.send(@current_filter).page(params[:page])
    end

    if @process.proposals_phase.started? || (current_user && current_user.administrator?)
      legislation_proposal_votes(@proposals)
      render :proposals
    else
      render :phase_not_open
    end
  end

  private

    def process_for_download
      Legislation::Process.send(@current_filter).order(start_date: :desc)
    end

    def member_method?
      params[:id].present?
    end

    def set_process
      return if member_method?
      @process = ::Legislation::Process.find(params[:process_id])
    end
end
