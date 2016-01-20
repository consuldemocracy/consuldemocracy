namespace :proposals do
  desc "Updates all proposals by recalculating their hot_score"
  task touch: :environment do
    Proposal.find_in_batches do |proposals|
      proposals.each(&:save)
    end
  end

  desc "Import proposals from a xls file given an url"
  task import: :environment do
    file_url = "#{Rails.root}/tmp/proposals.xlsx"
    ProposalXLSImporter.new(file_url).import
  end
end
