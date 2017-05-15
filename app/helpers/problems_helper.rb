module ProblemsHelper

  def valid_problems
    Problem.all.where('"starts_at" < ? AND "ends_at" > ?', Date.today, Date.today)
  end

end
