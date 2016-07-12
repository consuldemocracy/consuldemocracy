class BenchesController < ApplicationController
  skip_authorization_check

  def index
    @benches = Bench.all
  end

end