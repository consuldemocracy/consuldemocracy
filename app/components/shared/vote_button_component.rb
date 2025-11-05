# app/components/shared/vote_button_component.rb
class Shared::VoteButtonComponent < ApplicationComponent
  attr_reader :votable, :weight, :options, :is_legacy_call
  use_helpers :current_user, :can?

  def initialize(votable, value: nil, weight: nil, **options)
    @votable = votable
    @options = options

    if weight.nil?
      @is_legacy_call = true
      @weight = (value == "yes") ? 1 : -1
    else
      @is_legacy_call = false
      @weight = weight
    end
  end

  private

  def icon_class
    case @weight
    when 1  then "fas fa-thumbs-up"
    when -1 then "fas fa-thumbs-down"
    when 0  then "fas fa-question-circle"
    else "fas fa-circle"
    end
  end

  def path
    if is_this_the_active_vote?
      polymorphic_path(current_vote) # DELETE
    elsif user_has_voted?
      polymorphic_path(current_vote) # PATCH
    else
      # POST (Create)
      if @is_legacy_call
        polymorphic_path([votable, Vote.new], value: legacy_value_string)
      else
        polymorphic_path([votable, Vote.new])
      end
    end
  end
  
  def component_options
    params_hash = nil # Initialize as nil, NOT {}

    if is_this_the_active_vote?
      # --- DELETE ---
      # This path is working.
      return { "aria-pressed": true, method: :delete, remote: can?(:destroy, current_vote) }
    
    elsif user_has_voted?
      # --- PATCH ---
      # This path is working. Both new and legacy PATCH calls need the same params.
      params_hash = { vote: { vote_weight: weight, vote_flag: flag_for_weight } }
      return { "aria-pressed": false, method: :patch, params: params_hash, remote: can?(:update, current_vote) }

    else
      # --- POST ---
      # This is the path that was broken.
      unless @is_legacy_call
        # This is a NEW create call (Debates). It needs params in the body.
        params_hash = { vote: { vote_weight: weight, vote_flag: flag_for_weight } }
      end
      # If it *is* a legacy call, params_hash remains `nil`.
      # This is correct and forces `button_to` to use the query string from `path`.
      return { "aria-pressed": false, method: :post, params: params_hash, remote: can?(:create, vote_for_permission_check) }
    end
  end
 

  def legacy_value_string
    (@weight == 1) ? "yes" : "no"
  end

  def current_vote
    @current_vote ||= Vote.find_by(
      votable: votable,
      voter: current_user,
      vote_scope: nil
    )
  end

  def user_has_voted?
    current_vote.present?
  end

  def is_this_the_active_vote?
    user_has_voted? && current_vote.vote_weight == weight
  end

  def vote_for_permission_check
    @vote_for_permission_check ||= votable.votes_for.build(voter: current_user, vote_scope: nil)
  end

  def flag_for_weight
    weight > 0
  end
end