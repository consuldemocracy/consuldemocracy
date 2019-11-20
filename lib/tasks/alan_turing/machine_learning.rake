require "csv"

namespace :db do
  desc "Import data from the machine learning Comments Summary"
  task machine_learning_summary_comments: :environment do
    csv_file = "lib/tasks/alan_turing/ml_summary_comments.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      attributes["commentable_type"] = "Proposal"
      summary_comments = SummaryComment.create!(attributes)
      print "." if (summary_comments.id % 100) == 0
    end
  end
end
