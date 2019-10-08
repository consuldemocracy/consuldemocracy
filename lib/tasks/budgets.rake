namespace :budgets do
  namespace :email do

    desc "Sends emails to authors of selected investments"
    task selected: :environment do
      Budget.last.email_selected
    end

    desc "Sends emails to authors of unselected investments"
    task unselected: :environment do
      Budget.last.email_unselected
    end

  end

  desc "Update investments original_heading_id with current heading_id"
  task set_original_heading_id: :environment do
    puts "Starting"
    Budget::Investment.find_each do |investment|
      investment.update_column(:original_heading_id, investment.heading_id)
      print "."
    end
    puts "Finished"
  end

end
