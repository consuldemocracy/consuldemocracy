(1..17).each do |code|
  SDG::Goal.where(code: code).first_or_create!
end
