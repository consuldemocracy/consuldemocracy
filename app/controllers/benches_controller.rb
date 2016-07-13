class BenchesController < ApplicationController
  skip_authorization_check

  def index
    @benches = Bench.all
    load_vote
  end

  def vote
    @bench = Bench.find(params[:id])
    @bench.register_vote(current_user, 'yes')
    redirect_to thanks_benches_path
  end

  def thanks
    load_vote
  end

  private

    def load_vote
      if current_user && current_user.voted_for?(Bench)
        @bench = Bench.voted_by(current_user)
      end
    end
end