class Shared::VoteButtonComponent < ApplicationComponent
  attr_reader :votable, :value, :options
  use_helpers :current_user, :can?

  def initialize(votable, value:, **options)
    @votable = votable
    @value = value
    @options = options
  end

  private

    def path
      if already_voted?
        polymorphic_path(vote)
      else
        polymorphic_path(vote, value: value)
      end
    end

    def default_options
      if already_voted?
        {
          "aria-pressed": true,
          method: :delete,
          remote: can?(:destroy, vote)
        }
      else
        {
          "aria-pressed": false,
          method: :post,
          remote: can?(:create, vote)
        }
      end
    end

    def vote
      @vote ||= Vote.find_or_initialize_by(votable: votable, voter: current_user, vote_flag: parsed_value)
    end

    def already_voted?
      vote.persisted?
    end

    def parsed_value
      value == "yes"
    end
end
