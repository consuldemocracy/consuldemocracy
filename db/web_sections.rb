%w[homepage debates proposals budgets help_page sdg].each do |section|
  WebSection.where(name: section).first_or_create!
end
