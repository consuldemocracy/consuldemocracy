module RandomSeed
  extend ActiveSupport::Concern

  def set_random_seed
    seed = (params[:random_seed] || session[:random_seed] || rand(10_000_000)).to_i

    session[:random_seed] = seed
    params[:random_seed] = seed
  end
end
