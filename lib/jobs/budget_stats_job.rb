BudgetStatsJob = Struct.new(:budget, :city_heading) do
  def perform
    @namespace = "budget_#{budget.id}_balloting_stats"
    city_heading_id = city_heading.present? ? city_heading.id : nil

    return unless regenerate?

    Stat.named(@namespace, 'stats', "user_count").set_value budget.ballots.select {|ballot| ballot.lines.any? }.count
    Stat.named(@namespace, 'stats', "vote_count").set_value budget.lines.count
    Stat.named(@namespace, 'stats', "user_count_in_city").set_value(budget.ballots.select {|ballot| ballot.lines.where(heading_id: city_heading_id).exists?}.count)
    Stat.named(@namespace, 'stats', "user_count_in_district").set_value(budget.ballots.select {|ballot| ballot.lines.where(heading_id: (budget.heading_ids - [city_heading_id])).exists?}.count)
    Stat.named(@namespace, 'stats', "user_count_in_city_and_district").set_value((budget.ballots.select {|ballot| ballot.lines.where(heading_id: city_heading_id).exists?}.map(&:id) & budget.ballots.select {|ballot| ballot.lines.where(heading_id: (budget.heading_ids - [city_heading_id])).exists?}.map(&:id)).count)

    vote_count_by_heading = budget.lines.group(:heading_id).count
    vote_count_by_heading.default = 0
    user_count_by_district = User.where.not(balloted_heading_id: nil).group(:balloted_heading_id).count
    user_count_by_district.default = 0

    budget.headings.each do |heading|
      Stat.named(@namespace, 'vote_count_by_heading', heading.name).set_value vote_count_by_heading[heading.id]
      if heading.id != city_heading.id
        Stat.named(@namespace, 'user_count_by_district', heading.name).set_value user_count_by_district[heading.id]
      end
    end

    Stat.set(@namespace, 'stats', 'updated', (@updated_value + 1))
  end

  def frequency
    10.minutes
  end

  def regenerate?
    updated = Stat.named(@namespace, 'stats', 'updated')
    @updated_value = updated.value || 0
    return true if !updated.persisted?
    return true if updated.updated_at < frequency.ago
    false
  end
end