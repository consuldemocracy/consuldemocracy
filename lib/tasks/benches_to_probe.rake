namespace :temp do
  desc "Migrates benches feature to custom probe"
  task benches_to_probe: :environment do |t|
    town_planning = Probe.create!(codename: "town_planning")

    Bench.find_each do |bench|
      option = ProbeOption.create(probe_id: town_planning.id, name: bench.name, code: bench.code)
      Vote.where(votable_type: "Bench", votable_id: bench.id).each do |vote|
        ProbeSelection.create(probe_id: town_planning.id, probe_option_id: option.id, user_id: vote.voter_id)
      end
    end
  end

end
