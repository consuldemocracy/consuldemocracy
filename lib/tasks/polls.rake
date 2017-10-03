require 'fileutils'

namespace :polls do

desc "Create second citizen poll"
  task setup: :environment do
    # tricky to destroy, dependent on existent results, use only in dev env
    # destroy_all

    (1..10).each do |i|
      poll = Poll.find_or_initialize_by(name: poll_attributes(i)[:name])
      poll.attributes = poll_attributes(i)
      if poll.save
        print "."
      else
        puts poll.errors.first
      end
    end
  end

  def poll_attributes(i)
    { name: "Rehabilitar la plaza #{main_square_names[i]}",
      starts_at: Date.yesterday,
      ends_at: 1.week.from_now,
      geozone_restricted: false,
      questions_attributes: [
        { title: "¿Quieres rehabilitar la plaza #{main_square_names[i]}?",
          valid_answers: "Sí, No",
          author: User.first,
          author_visible_name: author_name,
          poll: Poll.last
          },
          title: "¿Qué plaza te gusta más?",
          valid_answers: "Plaza X, Plaza Y",
          author: User.first,
          author_visible_name: author_name,
          poll: Poll.last
      ]
    }
  end

  def author_name
    "Ayuntamiento de Madrid"
  end

  def main_square_names
    ["Plaza Duquesa Osuna",
     "Plaza Remonta",
     "Plaza Vaguada",
     "Plaza Civica Lucero",
     "Plaza Emperatriz",
     "Plaza Puerto Canfranc",
     "Plaza Encuentro",
     "Plaza Misterios",
     "Plaza Civica Mar Cristal",
     "Plaza Mayor Villaverde",
     "Plaza Civica San Blas"]
  end

  def destroy_all
    Poll::Answer.destroy_all
    Poll::Question.all.map(&:really_destroy!)
    Poll::Voter.destroy_all
    Poll::BoothAssignment.destroy_all
    Poll::OfficerAssignment.destroy_all
    Poll.destroy_all
  end
end