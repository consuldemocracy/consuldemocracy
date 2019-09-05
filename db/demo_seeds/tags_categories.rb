section "Creating DEMO Tags Categories" do
  ["Sustainability", "Sports", "Participation", "Transparency", "Media", "Social Rights",
   "Safety and Emergencies", "Environment", "Districts", "Culture", "Equity", "Mobility",
   "Urbanism", "Health", "Economy"].each do |category|
    ActsAsTaggableOn::Tag.category.create!(name: category, kind: "category")
  end
  ["Sustainable urban development", "human rights", "Bikes", "metro", "Right to education", "housing", "food",
   "Right to culture", "Right to food and quality water", "trees", "Education", "urbanism", "cycling",
   "regulation", "price", "cars", "youask", "pollution", "children", "Access to information",
   "Food and quality water", "fountains", "Decent work", "benches", "Energy", "squares", "sustainable",
   "green", "transport", "bus", "Animals", "Buildings", "Streets", "Social", "Music", "Parks", "Repairs",
   "environment"].each do |tag|
    ActsAsTaggableOn::Tag.category.create!(name: tag)
  end
end

