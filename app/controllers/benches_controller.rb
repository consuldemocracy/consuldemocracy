class BenchesController < ApplicationController
  skip_authorization_check

  def index
    @benches = Bench.all
  end

  def vote
    @bench = Bench.find(params[:id])
    @bench.register_vote(current_user, 'yes')
    redirect_to thanks_benches_path
  end

  def thanks
  end

end