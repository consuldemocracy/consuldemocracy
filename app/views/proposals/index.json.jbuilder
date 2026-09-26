json.array! @proposals do |proposal|
  json.merge! JSON.parse(render(Proposals::ProposalComponent.new(proposal)))
end
