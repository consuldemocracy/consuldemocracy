module ProblemsHelper

  def valid_problems
    Problem.all.where('"starts_at" < ? AND "ends_at" > ?', Date.today, Date.today)
  end

  def has_active_problem?
    Problem.all.where("active").any? 
  end

  def active_problem
    Problem.all.where("active").first
  end

end
