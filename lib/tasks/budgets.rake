namespace :budgets do

  describe "resends all unfeasible emails with a correction in the subject"
  task :resend_unfeasible_emails do
    valid_emails = []
    invalid_emails = []

    budget = Budget.last
    budget.investments.unfeasible.each do |investment|
      if investment.try(:author).try(:email).present?
        investment.send_unfeasible_email
        valid_emails << investment.id
      else
        invalid_emails << investment.id
      end
    end

    puts "Valid #{valid_emails.count}"
    puts "Invalid #{invalid_emails.count}"
  end

end