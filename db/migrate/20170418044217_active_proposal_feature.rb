class ActiveProposalFeature < ActiveRecord::Migration
  def change

    Setting.find_by_key('votes_for_proposal_success').update!(value: 1000_000_000) # Very-high value to avoid closing
    Setting.find_by_key('max_votes_for_proposal_edit').update!(value:0) # Proposals can not be edited
    if Setting.find_by_key('feature.proposals').nil?
      Setting.create(key: 'feature.proposals', value: 't')
    else
      Setting.find_by_key('feature.proposals').update!(value:'t') # Proposals can not be edited
    end
  end
end
