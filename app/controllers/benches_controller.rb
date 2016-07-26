class BenchesController < ApplicationController
  skip_authorization_check

  def index
    @benches = Bench.all.order(cached_votes_up: :desc)
    load_vote
  end

  private

    def load_vote
      if current_user && current_user.voted_for_any?(Bench)
        @bench = Bench.voted_by(current_user)
      end
    end
end