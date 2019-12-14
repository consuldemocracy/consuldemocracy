require "csv"

namespace :db do
  desc "Recalculate data from the CSV files"
  task alan_turing_comments_proposals: :environment do

    puts "Recalculating Proposal's Comments"

    Proposal.find_each do |proposal|
      comments_number = Comment.where(commentable_id: proposal.id).count
      proposal.update_columns(comments_count: comments_number)
      print "." if (proposal.id % 100) == 0
    end
    puts "\nComments recalculated!"
  end
end
