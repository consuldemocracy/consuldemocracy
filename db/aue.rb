(1..10).to_a.shuffle.each do |code|
  AUE::Goal.where(code: code).first_or_create!
end
