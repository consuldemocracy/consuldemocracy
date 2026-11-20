json.array! @proposals do |proposal|
  json.merge! JSON.parse(render(Api::Proposals::ProposalComponent.new(proposal)))
end
