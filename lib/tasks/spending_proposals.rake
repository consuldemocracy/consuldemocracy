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
    proposals_ids = [4225,4023,5515,5152,4884,4881,3606,4434,4252,4459,4914,5412,5451,5277,38,4899,4913,4966,5000,4753,4720,4735,4754,4750,4763,4747,4479,3776,3778,3973,3983,3997,4014,4056,4068,4083,3781,3966,4082,4890,4515,4156,4892,4145,4894,4850,4537,4867,4824,4597,4622,5280,5148,4689,5110,5187,5189,4984,5185,5088,5338,4658,5047,5060,4782,4241,5218,4979,5035,5369,5393,4744,4665,4661,4956,3792,4504,4307,4506,5176,4453,4923,3989,4959,3979,5041,4980,3987,3985,3885,4464,5040,5192,4727,5006,5038,4493,4480,4474,4488,4485,4718,4732,4785,4348,4347,4618,4736,4393,4364,4390,5496,4400,4375,4381,4384,5066,4396,4399,4390,4378,5346,4380,5359,4383,4363,5341,5336,5333,4421,4424,5286,4815,4986,5164,4991,4496,4595,5432,4743,5427,4836,4592,3716,5362,4120,4306]
    proposals_ids.each do |proposal_id|
      proposal = SpendingProposal.find(proposal_id)
      proposal.update(forum: true)
      puts "."
    end
  end
end