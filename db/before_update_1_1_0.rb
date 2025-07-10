# Tarea para exportar los datos del campo internal_comments del modelo Budget::Investment
# Una vez exportado hay que mover el archivo en el directorio data del proyecto actualizado
csv_investment_internal_comments_file = "#{Rails.root}/budgets_investments_internal_comments.csv"
csv_investment_internal_comments_headers = %w[id internal_comments]
CSV.open(csv_investment_internal_comments_file, "w", write_headers: true, headers: csv_investment_internal_comments_headers, col_sep: "|") do |writer|
  Budget::Investment.where.not(internal_comments: [nil, ""]).find_each do |investment|
    writer << [investment.id, investment.internal_comments]
  end
end

# Tarea para exportar los datos de los campos description de budgets
csv_budget_attributes_file = "#{Rails.root}/budgets_attributes.csv"
budgets_attributes = %w[id description_accepting description_reviewing description_selecting description_valuating description_balloting description_reviewing_ballots description_finished]
CSV.open(csv_budget_attributes_file, "w", write_headers: true, headers: budgets_attributes, col_sep: "|") do |writer|
  Budget.find_each do |budget|
    budgets_attributes_values = budgets_attributes.map { |budget_attribute| budget.send(budget_attribute) }
    writer << budgets_attributes_values
  end
end
