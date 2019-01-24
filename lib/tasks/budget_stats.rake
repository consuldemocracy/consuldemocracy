namespace :budgets do
  namespace :stats do

    desc "Calculate current balloting stats"
    task balloting: :environment do
      Budget.where(phase: ["balloting", "reviewing_ballots", "finished"]).each do |budget|
        namespace = "budget_#{budget.id}_balloting_stats"
        city_heading = budget.city_heading
        city_heading_id = city_heading.present? ? city_heading.id : nil

        Stat.named(namespace, 'stats', "user_count").set_value budget.ballots.select {|ballot| ballot.lines.any? }.count
        Stat.named(namespace, 'stats', "vote_count").set_value budget.lines.count
        Stat.named(namespace, 'stats', "user_count_in_city").set_value(budget.ballots.select {|ballot| ballot.lines.where(heading_id: city_heading_id).exists?}.count)
        Stat.named(namespace, 'stats', "user_count_in_district").set_value(budget.ballots.select {|ballot| ballot.lines.where(heading_id: (budget.heading_ids - [city_heading_id])).exists?}.count)
        Stat.named(namespace, 'stats', "user_count_in_city_and_district").set_value((budget.ballots.select {|ballot| ballot.lines.where(heading_id: city_heading_id).exists?}.map(&:id) & budget.ballots.select {|ballot| ballot.lines.where(heading_id: (budget.heading_ids - [city_heading_id])).exists?}.map(&:id)).count)

        vote_count_by_heading = budget.lines.group(:heading_id).count
        vote_count_by_heading.default = 0
        user_count_by_district = User.where.not(balloted_heading_id: nil).group(:balloted_heading_id).count
        user_count_by_district.default = 0

        budget.headings.each do |heading|
          Stat.named(namespace, 'vote_count_by_heading', heading.name).set_value vote_count_by_heading[heading.id]
          if heading.id != city_heading_id
            Stat.named(namespace, 'user_count_by_district', heading.name).set_value user_count_by_district[heading.id]
          end
        end
      end
    end

  end

end
