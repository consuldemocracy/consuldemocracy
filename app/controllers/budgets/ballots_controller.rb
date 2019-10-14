module Budgets
  class BallotsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :budget
    before_action :load_ballot, :set_random_seed, :load_group, :load_heading, :load_investments
    before_action :verify_lock, only: [:confirm, :commit, :resend_code]
    before_action :verify_verified_but_not_phonenumber! # GET-230
    after_action :store_referer, only: [:show]

    def show
      authorize! :show, @ballot
      session[:ballot_referer] = request.referer
      render template: "budgets/ballot/show"
    end

    # GET-125
    def confirm
      authorize! :confirm, @ballot

      if @ballot.completed?
        if @ballot.build_confirmation_with_code(current_user)
          Lock.increase_tries(current_user)
          redirect_to budget_ballot_path, notice: 'Se le ha enviado un código para confirmar su votación'
        else
          redirect_to budget_ballot_path, alert: 'No se ha podido enviar el  código de confirmación'
        end
      end
    end

    def resend_code
      authorize! :resend_code, @ballot

      if @ballot.completed? && @ballot.notified? && @ballot.unconfirmed?
        if @ballot.resend_confirmation_code(current_user)
          Lock.increase_tries(current_user)
          redirect_to budget_ballot_path, notice: 'Se le ha enviado un nuevo código'
        else
          redirect_to budget_ballot_path, alert: 'No se le pudo enviar el código de confirmación'
        end
      end
    end

    def commit
      authorize! :commit, @ballot

      provided_code = params[:confirmation] ? params[:confirmation][:provided_sms_confirmation_code]  : nil

      unless provided_code.blank?
        if @ballot.notified? && @ballot.unconfirmed?
          Lock.increase_tries(current_user)
          if @ballot.confirm(provided_code , current_user)
            redirect_to budget_ballot_path, notice: 'Su votación se ha presentado correctamente'
          else
            redirect_to budget_ballot_path, alert: 'Código no válido'
          end
        end
      else
        redirect_to budget_ballot_path, alert: 'Debe proporcionar un código para validar su votación'
      end
    end

    def discard
      authorize! :discard, @ballot

      if @ballot.confirmed_or_notified?
        if @ballot.discard(current_user)
          redirect_to budget_ballot_path, alert: 'Su votación ha sido descartada'
        else
          redirect_to budget_ballot_path, alert: 'Su votación no se ha podido descartar'
        end
      end
    end

    private

    def verify_lock
      if current_user.locked?
        redirect_to budget_ballot_path, alert: t('verification.alert.lock')
      end
    end

    def load_ballot
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
    end

    #GET-107
    def load_group
      unless @ballot.group.nil?
        @group = @ballot.group
      else
        if params[:group_id]
          @group = @budget.groups.find(params[:group_id])
        end
      end
    end

    def store_referer
      session[:ballot_referer] = request.referer
    end

    def load_heading
      if params[:heading_id]
        @heading = @group.headings.find(params[:heading_id])
      else
        if @group
          @heading = @group.headings.first
        end
      end
    end

    def load_investments
      if @group
        @investments = @budget.investments.where(group_id: @group.id, heading_id: @heading.id).where(selected: true).sort_by_random
      end
    end

    def set_random_seed

      Budget::Investment.connection.execute "select setseed(#{@ballot.random_seed})"
    end
  end
end
