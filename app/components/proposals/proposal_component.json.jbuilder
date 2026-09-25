fields.each do |field|
  json.set! field, proposal.send(field)
end
