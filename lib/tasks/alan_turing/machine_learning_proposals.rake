require "csv"

namespace :db do
  desc "Import data from the CSV files"
  task machine_learning_related_proposals: :environment do
    puts "Asigning Related Content to Proposals"
    csv_file = "lib/tasks/alan_turing/ml_related_proposals.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: false) do |line|
      list = line.to_a
      proposal_id = list.first
      list.delete(proposal_id)
      list.each do |related_proposal_id|
        if related_proposal_id.present?
          unless RelatedContent.exists?(parent_relationable_id: proposal_id,
                                        child_relationable_id: related_proposal_id)
            related_content = RelatedContent.create!(parent_relationable_id: proposal_id,
                                                      parent_relationable_type: "Proposal",
                                                      child_relationable_id: related_proposal_id,
                                                      child_relationable_type: "Proposal",
                                                      author_id: 1)
            print "." if (related_content.id % 100) == 0
          end
        end
      end
    end
    puts "\nRelated content assigned to Proposals!"
  end
end
