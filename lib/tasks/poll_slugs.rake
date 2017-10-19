namespace :temp do

  desc "Create slugs for polls"
  task polls_slugs: :environment do

    polls = Poll.all

    polls.each do |poll|
      poll.update_attributes(slug: poll.name.to_s.parameterize)

      if poll.save
        print "."
      else
        puts poll.errors.first
      end
    end
  end
end