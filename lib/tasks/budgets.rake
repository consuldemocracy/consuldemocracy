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
  end

  desc "Updates custom links for budgets"
  task custom_links: :environment do
    Budget.find_each do |budget|
      unless budget.main_link_url.present? && budget.main_link_text.present?
        if budget.main_button_url.present?
          budget.main_link_url = budget.main_button_url
          budget.save!
        end
        if budget.main_button_text.present?
          budget.main_link_text = budget.main_button_text
          budget.save!
        end
      end
    end

    Budget::Phase.find_each do |phase|
      if Budget.find_by(id: phase.budget_id)
        unless phase.main_link_url.present? && phase.main_link_text.present?
          if phase.main_button_url.present?
            phase.main_link_url = phase.main_button_url
            phase.save!
          end
          if phase.main_button_text.present?
            phase.main_link_text = phase.main_button_text
            phase.save!
          end
        end
      end
    end
  end
end
