namespace :spending_proposals do
  desc "Sends an email to the authors of unfeasible spending proposals"
  task send_unfeasible_emails: :environment do
    SpendingProposal.find_each do |spending_proposal|
      if spending_proposal.unfeasible_email_pending?
        spending_proposal.send_unfeasible_email
        puts "email sent for proposal #{spending_proposal.title}"
      else
        puts "this proposal is feasible: #{spending_proposal.title}"
      end
    end
  end

  desc "Updates all spending proposals to recalculate their tsv and responsible_name columns"
  task touch: :environment do
    SpendingProposal.find_in_batches do |spending_proposal|
      spending_proposal.each(&:save)
    end
  end

end
