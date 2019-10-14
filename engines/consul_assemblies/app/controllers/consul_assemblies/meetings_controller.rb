require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class MeetingsController < ApplicationController
    include CommentableActions
    skip_authorization_check

    helper_method :resource_model, :resource_name
    respond_to :html, :js

    before_action :load_assemblies, except: [:show]

    def show
      @current_order = :newest
      scope = ConsulAssemblies::Meeting
      scope = scope.published unless @current_user && (@current_user.administrator?)
      @meeting = scope.find(params[:id])
      super
    end

    def set_meeting_votes(votes);end

    def index
      @meetings = ConsulAssemblies::Meeting.published.order(scheduled_at: 'desc')

      @q = @meetings.ransack(params[:q])
      @meetings = @q.result.page(params[:page])
    end

    private

    def current_order
      'scheduled_at'
    end

    def resource_model
      ConsulAssemblies::Meeting
    end

    def resource_name
      'meeting'
    end


    def load_assemblies
      @assemblies = ConsulAssemblies::Assembly.order('name asc')
    end

  end
end
