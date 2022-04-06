class DashboardController < Dashboard::BaseController
  helper_method :dashboard_action, :active_resources, :course
  before_action :set_done_and_pending_actions, only: [:recommended_actions, :progress]
  before_action :authorize_dashboard, except: :publish

  def show
  end

  def publish
    authorize! :publish, proposal

    proposal.publish
    redirect_to progress_proposal_dashboard_path(proposal), notice: t("proposals.notice.published")
  end

  def progress
  end

  def community
  end

  def recommended_actions
  end

  def messages
  end

  def related_content
  end

  private

    def active_resources
      @active_resources ||= Dashboard::Action.active
                                             .resources
                                             .by_proposal(proposal)
                                             .order(required_supports: :asc, day_offset: :asc)
    end

    def course
      @course ||= Dashboard::Action.course_for(proposal)
    end

    def set_done_and_pending_actions
      @done_actions = proposed_actions.joins(:proposals).where(proposals: { id: proposal.id })
      @pending_actions = proposed_actions - @done_actions
    end

    def authorize_dashboard
      authorize! :dashboard, proposal
    end
end
