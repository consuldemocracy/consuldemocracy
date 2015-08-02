class VotesController < ApplicationController
  before_action :set_debate
  before_action :set_resource
  before_action :authenticate_user!
  respond_to :html, :js

  def create
    register_vote
    respond_with @debate
  end

  private

    def set_resource
      @resource = resource_model.find(params["#{resource_name + "_id"}"])
    end

    def resource_name
      @resource_name ||= params[:votable_type]
    end

    def resource_model
      resource_name.capitalize.constantize
    end

    def set_debate
      @debate = Debate.find(params[:debate_id])
    end

    def register_vote
      @resource.vote_by voter: current_user, vote: params[:value]
    end

    def notice
      @resource.vote_registered? ? I18n.t("votes.notice_thanks") : I18n.t("votes.notice_already_registered")
    end

end
