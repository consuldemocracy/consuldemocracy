require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class AssembliesController < ApplicationController
    include FeatureFlags
    include FlagActions


    before_action :authenticate_user!, except: [:index, :show]
    before_action :load_assembly_type, only: [:index, :show]
    before_action :load_active_assemblies, only: [:show, :index]
    before_action :load_assembly, only: [:show, :index]
    before_action :load_meetings, only: [:index, :show]


    feature_flag :assemblies

    has_filters %w{open next past}, only: [:index, :show]


    skip_authorization_check
    helper_method :resource_model, :resource_name
    respond_to :html, :js


    def index; end

    private

    def load_assembly_type
      @assembly_type = ConsulAssemblies::AssemblyType.find(params[:assembly_type_id]) if params[:assembly_type_id]
    end

    def load_active_assemblies
      @assemblies = ConsulAssemblies::Assembly.order(:name)
      @assemblies = @assemblies.where(assembly_type_id: @assembly_type) if @assembly_type
    end

    def load_assembly
      @assembly = ConsulAssemblies::Assembly.find(params[:assembly_id]) if params[:assembly_id]
    end

    def load_meetings
      @meetings = ConsulAssemblies::Meeting.published.order(scheduled_at: 'asc')
      @meetings = @meetings.where(assembly_id: @assemblies) if @assemblies
      @meetings = @meetings.without_held unless params[:include_held]
      @meetings = @meetings.where(assembly_id: @assembly) if @assembly
    end
  end
end
