namespace :campagins do

  desc "Recalculates all the comment counters for debates and proposals"
  task create: :environment do
    3.times { |i| Campaign.create!(name: "Campaign#{i+1}", track_id: rand(2**32..2**64)) }
  end

end
