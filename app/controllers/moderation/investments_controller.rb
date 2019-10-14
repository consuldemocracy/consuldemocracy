class Moderation::InvestmentsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{pending_flag_review with_pending_attachment_verification with_attachment_verified with_attachment_rejected  all}, only: :index
  has_orders %w{created_at created_at_desc}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource :class => "Budget::Investment"

  #GET-62 Modified moderation controller for Budget::Investments

  def index
    @resources = @resources
                     .send(@current_filter)
                     .send("sort_by_#{@current_order}")
                     .page(params[:page])
                     .per(50)
    set_resources_instance
  end

  def moderate
    set_resource_params
    @resources = @resources.where(id: params[:resource_ids])

    if params[:verify_attachments].present?
      @resources.accessible_by(current_ability, :hide).each {|resource| resource.verify_attachment!(current_user)}
      redirect_to request.query_parameters.merge(action: :index)
    elsif params[:reject_attachments].present?
      @resources.accessible_by(current_ability, :hide).each {|resource| resource.reject_attachment!(current_user)}
      redirect_to request.query_parameters.merge(action: :index)
    else
      super
    end
  end

  private

    def resource_name
      @resource_name ||= 'investment'
    end

    def set_resources_instance
      instance_variable_set("@investments", @resources)
    end

    def resource_model
      Budget::Investment
    end
end
