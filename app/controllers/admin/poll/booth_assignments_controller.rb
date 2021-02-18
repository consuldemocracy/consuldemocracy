class Admin::Poll::BoothAssignmentsController < Admin::Poll::BaseController
  before_action :load_poll, except: [:create]

  def index
    @booth_assignments = @poll.booth_assignments.includes(:booth).order("poll_booths.name")
                              .page(params[:page]).per(50)
  end

  def search_booths
    load_search
    @booths = ::Poll::Booth.quick_search(@search)
    respond_to do |format|
      format.js
    end
  end

  def show
    included_relations = [:recounts, :voters, officer_assignments: [officer: [:user]]]
    @booth_assignment = @poll.booth_assignments.includes(*included_relations).find(params[:id])
    @voters_by_date = @booth_assignment.voters.group_by { |v| v.created_at.to_date }
    @partial_results = @booth_assignment.partial_results
    @recounts = @booth_assignment.recounts
  end

  def create
    @poll = Poll.find(booth_assignment_params[:poll_id])
    @booth = Poll::Booth.find(booth_assignment_params[:booth_id])
    @booth_assignment = ::Poll::BoothAssignment.new(poll: @poll,
                                                    booth: @booth)

    @booth_assignment.save!

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def destroy
    @booth_assignment = @poll.booth_assignments.find(params[:id])
    @booth = @booth_assignment.booth

    @booth_assignment.destroy!

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def manage
    @booths = ::Poll::Booth.all.order(name: :asc).page(params[:page]).per(300)
    @poll = Poll.find(params[:poll_id])
  end

  private

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find(params[:id])
    end

    def booth_assignment_params
      params.permit(:booth_id, :poll_id)
    end

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end
end
