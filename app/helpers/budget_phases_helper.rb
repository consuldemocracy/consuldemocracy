module BudgetPhasesHelper
  def phase_begin_date(phase)
    "#{l(phase.starts_at.to_date)} 00:00"
  end

  def phase_end_date(phase)
    "#{l(phase.ends_at.to_date - 1)} 23:59"
  end
end
