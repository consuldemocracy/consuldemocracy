namespace :proposals do
  desc "Updates all proposals by recalculating their hot_score"
  task touch: :environment do
    Proposal.find_in_batches do |proposals|
      proposals.each(&:save)
    end
  end

  desc "Import proposals from a xls file given an url"
  task :import, [:url] => :environment do |task, args|
    if args.url.blank?
      puts "Usage: rake proposals:import[url]"
    else
      ProposalXLSImporter.new(open(args.url)).import
    end
  end
end
