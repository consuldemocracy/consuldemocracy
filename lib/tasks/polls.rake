namespace :polls do
  desc "Changes the polls ending date to the end of the day"
  task set_ends_at_to_end_of_day: :environment do
    ApplicationLogger.new.info "Adding time to the date where a poll ends"

    Poll.find_each do |poll|
      poll.update_column :ends_at, poll.ends_at.end_of_day.beginning_of_minute
    end
  end
end
