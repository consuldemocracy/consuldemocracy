namespace :communities do

  desc "Associate community to proposals and budget investments"
  task associate_community: :environment do

    Proposal.all.each do |proposal|
      if proposal.community.blank?
        proposal.update(community: Community.create)
      end
    end

    Budget::Investment.all.each do |investment|
      if investment.community.blank?
        investment.update(community: Community.create)
      end
    end
  end

  desc "Migrate communitable data to communitable columns"
  task migrate_communitable: :environment do
    (Proposal.all + Budget::Investment.all).each do |communitable|
      if communitable.community_id.present?
        community = Community.where(id: communitable.community_id).first

        if community
          community.update(
            communitable_id:    communitable.id,
            communitable_type:  communitable.class.name
          )
        else
          warn "WARNING: The community associated to #{communitable.class.name} "\
               "with ID #{communitable.id} no longer exists. "\
               "Consider running `rake communities: associate_community`"
        end
      else
        warn "WARNING: #{communitable.class.name} with ID #{communitable.id} "\
             "should have an associated community. "\
             "Consider running `rake communities: associate_community`"
      end
    end
  end
end
