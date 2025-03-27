class Officing::MenuComponent < ApplicationComponent
  attr_reader :voter_user
  use_helpers :current_user

  def initialize(voter_user:)
    @voter_user = voter_user
  end

  private

    def vote_collection_shift?
      current_user.poll_officer.officer_assignments.voting_days.where(date: Time.current.to_date).any?
    end

    def final_recount_shift?
      current_user.poll_officer.officer_assignments.final.where(date: Time.current.to_date).any?
    end
end
