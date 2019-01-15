section "Creating default Milestone Statuses" do
  Milestone::Status.create(name: I18n.t('seeds.budgets.statuses.studying_project'))
  Milestone::Status.create(name: I18n.t('seeds.budgets.statuses.bidding'))
  Milestone::Status.create(name: I18n.t('seeds.budgets.statuses.executing_project'))
  Milestone::Status.create(name: I18n.t('seeds.budgets.statuses.executed'))
end

section "Creating investment milestones" do
  [Budget::Investment, Proposal, Legislation::Process].each do |model|
    model.find_each do |record|
      rand(1..5).times do
        milestone = record.milestones.build(
          publication_date: Date.tomorrow,
          status_id: Milestone::Status.all.sample
        )

        I18n.available_locales.map do |locale|
          Globalize.with_locale(locale) do
            milestone.description = "Description for locale #{locale}"
            milestone.title = I18n.l(Time.current, format: :datetime)
            milestone.save!
          end
        end
      end
    end
  end
end

