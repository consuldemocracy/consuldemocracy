require 'fileutils'

namespace :polls do

desc "Create second citizen poll"
  task setup: :environment do
    destroy_all

    (0..10).each do |i|
      poll = Poll.new(name: poll_attributes(i)[:name])
      poll.attributes = poll_attributes(i)

      if poll.save
        print "."
      else
        puts poll.errors.first
      end

      add_images_for(poll, i)
    end
  end

  def poll_attributes(i)
    { name: "Remodelación de la #{main_square_names[i]}",
      description: config["description_for_poll"]["#{project_name(i)}"],
      summary: config["summary_for_poll"]["#{project_name(i)}"],
      starts_at: 1.week.ago,
      ends_at: 1.week.from_now,
      geozone_restricted: false,
      questions_attributes: [
        { title: "¿Consideras necesario remodelar la plaza?",
          author: User.first,
          author_visible_name: author_name,
          poll: Poll.last,
          question_answers_attributes: [
            { title: "No",
              description: ""
            },
            { title: "Sí",
              description: ""
            },
          ]
          },
          title: "En el caso de que se decida mayoritariamente remodelar la plaza ¿Cuál de los dos proyectos finalistas prefieres que se lleve a cabo?",
          author: User.first,
          author_visible_name: author_name,
          poll: Poll.last,
          question_answers_attributes: [
            { title: "Proyecto Y",
              description: config["desciption_for_answer"]["#{project_name(i)}/proyecto-y"]
            },
            { title: "Proyecto X",
              description: config["desciption_for_answer"]["#{project_name(i)}/proyecto-x"]
            }
          ]
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

  def project_name(i)
    main_square_names[i].parameterize
  end

  def images(answer, i)
    Dir["#{Rails.root}/public/main_squares/#{project_name(i)}/#{answer.title.parameterize}/*"].sort
  end

  def main_image(poll, i)
    Dir["#{Rails.root}/public/main_squares/#{project_name(i)}/*.jpg"].first
  end

  def build_image(path)
    return false unless path
    filename = path.split("/").last
    Image.new(attachment: File.new(path, "r"), title: config["title_for_image"][filename] || "unavailable", user: User.first)
  end

  def add_images_for(poll, i)
    set_poll_image(poll, i)
    set_answer_images(poll, i)
  end

  def set_poll_image(poll, i)
    main_image = main_image(poll, i)
    poll.image = build_image(main_image(poll, i))
  end

  def set_answer_images(poll, i)
    poll.questions.map(&:question_answers).flatten.each do |answer|
      images(answer, i).each do |image|
puts image
        answer.images << build_image(image)
      end
    end
  end

  def destroy_all
    if Rails.env.preproduction?
      Poll.update_all(ends_at: 1.month.ago)
    else
      Poll::Answer.destroy_all
      Poll::Question::Answer::Video.destroy_all
      Poll::Question::Answer.destroy_all
      Poll::Question.all.map(&:really_destroy!)
      Poll::Voter.destroy_all
      Poll::BoothAssignment.destroy_all
      Poll::OfficerAssignment.destroy_all
      Poll.destroy_all
    end
  end

  def config
    YAML.load(File.read("#{Rails.root}/public/main_squares/config.yml"))
  end

  namespace :polls do
    desc "Migrate Poll White/Null/Total Results to Poll Recounts"
    task migrate_to_recounts: :environment do
      %w(white null total).each do |type|
        "Poll::#{type.capitalize}Result".constantize.all.each do |result|
          recount = Poll::Recount.new
          recount.booth_assignment = result.booth_assignment
          recount.officer_assignment = result.officer_assignment
          recount["#{type}_amount"] = result.amount
          recount["#{type}_amount_log"] = result.amount_log
          recount.officer_assignment_id_log = result.officer_assignment_id_log
          recount.date = result.date
          recount.origin = result.origin
          recount.author = result.author
          recount.author_id_log = ":#{result.author.id}"
          puts "Error creating Poll Recount with ##{result.id} and result type ##{type} params, #{recount.errors}" unless recount.save
        end
      end
    end
  end
end

