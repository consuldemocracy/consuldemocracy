namespace :communities do

  desc "Associate community to proposals and budget investments"
  task associate_community: :environment do

    Proposal.find_each do |proposal|
      if proposal.community.blank?
        community = Community.create
        proposal.update(community_id: community.id)
      end
    end

    Budget::Investment.find_each do |investment|
      if investment.community.blank?
        community = Community.create
        investment.update(community_id: community.id)
      end
    end
  end

end
