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

  desc "Sets spending proposal as created by Forum"
  task set_forum: :environment do
    proposals_ids = [4926, 5255, 4801, 4716, 5078, 4526, 4635, 4830, 4730, 4946, 4719, 4576, 5227, 5297, 4353, 4147, 4789, 5224, 4673, 4671, 4670, 5345, 4101, 5326, 4760, 4757, 4681, 4655, 4438, 4429, 4371, 4368, 4367, 4366, 4362, 4359, 4356, 4355, 4352, 4350, 4349, 4346, 4345, 4343, 4340, 4339, 4338, 4336, 4335, 4333, 4330, 4943, 5061, 4932, 4948, 5037, 5055, 5061, 5043, 4277, 5059, 4947, 5050, 4945, 4276, 4267, 5063, 4940, 4994, 4183, 3971, 4590, 4111, 4113, 4693, 5193, 4739, 2757, 4393, 4364, 4390, 4400, 4375, 4381, 4384, 4396, 4399, 4378, 5346, 4380, 4383, 4363, 4424, 4373, 4967, 4965, 2142, 5341, 5336, 5333, 4421, 4994, 4183, 3971, 4590, 4111, 4113, 4693, 5193, 4739, 2757, 4058, 4332, 4137, 5328, 4125, 4422, 5098, 4144, 4376, 4099]
    proposals_ids.each do |proposal_id|
      proposal = SpendingProposal.find(proposal_id)
      proposal.update(forum: true)
      puts "."
    end
  end
end