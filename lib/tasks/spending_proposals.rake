namespace :spending_proposals do
  desc "Sends an email to the authors of unfeasible spending proposals"
  task send_unfeasible_emails: :environment do
    SpendingProposal.find_each do |spending_propsal|
      if spending_propsal.unfeasible_email_pending?
        spending_propsal.send_unfeasible_email
        puts "email sent for proposal #{spending_propsal.title}"
      else
        puts "this proposal is feasible: #{spending_propsal.title}"
      end
    end
  end

  desc "Updates all spending proposals to recalculate their tsv column"
  task touch: :environment do
    SpendingProposal.find_in_batches do |spending_propsal|
      spending_propsal.each(&:save)
    end
  end
end