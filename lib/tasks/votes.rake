namespace :votes do
  desc "Removes duplicate votes"
  task remove_duplicate_votes: :environment do
    logger = ApplicationLogger.new
    logger.info "Removing duplicate votes"

    Tenant.run_on_each do
      duplicate_ids = Vote.select(:voter_id, :voter_type, :votable_id, :votable_type)
                          .group(:voter_id, :voter_type, :votable_id, :votable_type)
                          .having("count(*) > 1")
                          .pluck(:voter_id, :voter_type, :votable_id, :votable_type)

      duplicate_ids.each do |voter_id, voter_type, votable_id, votable_type|
        votes = Vote.where(
                  voter_id: voter_id,
                  voter_type: voter_type,
                  votable_id: votable_id,
                  votable_type: votable_type
                )

        votes.excluding(votes.first).each do |vote|
          votable = vote.votable
          vote.delete

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          logger.info "Deleted duplicate record with ID #{vote.id} " \
                      "from the #{Vote.table_name} table " \
                      "with voter_id #{voter_id}, voter_type #{voter_type}, " \
                      "votable_id #{votable_id} and votable_type #{votable_type}" \
                      + tenant_info.to_s

          votable&.update_cached_votes
        end
      end
    end
  end

  desc "Resets hot_score to its new value"
  task reset_hot_score: :environment do
    models = [Debate, Proposal, Legislation::Proposal]

    models.each do |model|
      print "Updating votes hot_score for #{model}s"

      Tenant.run_on_each do
        model.find_each do |resource|
          new_hot_score = resource.calculate_hot_score
          resource.update_columns(hot_score: new_hot_score, updated_at: Time.current)
        end
      end
      puts " ✅ "
    end
    puts "Task finished 🎉 "
  end
end
