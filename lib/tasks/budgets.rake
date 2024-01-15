namespace :budgets do
  namespace :email do
    desc "Sends emails to authors of selected investments"
    task :selected, [:tenant] => :environment do |_, args|
      Tenant.switch(args[:tenant]) { Budget.current.email_selected }
    end

    desc "Sends emails to authors of unselected investments"
    task :unselected, [:tenant] => :environment do |_, args|
      Tenant.switch(args[:tenant]) { Budget.current.email_unselected }
    end

    desc "Sends emails to authors of unfeasible investments"
    task unfeasible: :environment do
      Budget.last.email_unfeasible
    end
  end
end
