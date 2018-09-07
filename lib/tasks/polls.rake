require 'fileutils'

namespace :polls do

  desc "Adds created_at and updated_at values to existing polls"
    task initialize_timestamps: :environment do
      Poll.update_all(created_at: Time.current, updated_at: Time.current)
    end

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
        add_documents_for(poll, i)
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
              { title: "En blanco",
                description: ""
              },
              { title: "No",
                description: ""
              },
              { title: "Sí",
                description: ""
              },
            ]
            },
            title: "En el caso de que se decida mayoritariamente remodelar la plaza ¿Cuál de los dos proyectos finalistas prefieres que se lleve a cabo?",
            author: User.first,
            author_visible_name: author_name,
            poll: Poll.last,
            question_answers_attributes: [
              { title: "En blanco",
                description: ""
              },
              { title: "Proyecto Y: #{project_y_names[i]}",
                description: config["desciption_for_answer"]["#{project_name(i)}/proyecto-y"]
              },
              { title: "Proyecto X: #{project_x_names[i]}",
                description: config["desciption_for_answer"]["#{project_name(i)}/proyecto-x"]
              }
            ]
        ]
      }
    end

    def author_name
      "Ayuntamiento de Madrid"
    end

    def folder_square_names
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

    def main_square_names
      ["Plaza de la Duquesa de Osuna (Barajas)",
       "Plaza de la Remonta (Tetuán)",
       "Plaza de la Vaguada (Fuencarral - El Pardo)",
       "Plaza Cívica de Lucero (Latina)",
       "Plaza de la Emperatriz (Carabanchel)",
       "Plaza del Puerto de Canfranc (Puente de Vallecas)",
       "Plaza del Encuentro (Moratalaz)",
       "Plaza de los Misterios (Ciudad Lineal)",
       "Plaza Cívica Mar de Cristal (Hortaleza)",
       "Plaza Mayor de Villaverde y Plaza de Ágata (Villaverde)",
       "Plaza Cívica de San Blas (San Blas - Canillejas)"]
    end

    def project_x_names
      ["Ad libitum",
       "60 x 60",
       "Naturnah",
       "Ba de Luz",
       "Del metro al Parterre",
       "Activa tu plaza",
       "Encuentros en la tercera plaza",
       "Quinto",
       "Greenfingers",
       "Polos opuestos",
       "Nos cruzamos en la plaza"]
    end

    def project_y_names
      ["Locus amoenus",
       "La Remonta a un paso",
       "La gran pérgola",
       "Historia natural",
       "Toma la calle",
       "Nos vemos en Canfranc",
       "Horizontes cívicos",
       "Link al verde",
       "Formas de vida",
       "Verde Villa",
       "Conectando San Blas"]
    end

    def project_name(i)
      folder_square_names[i].parameterize
    end

    def images(answer, i)
      Dir["#{Rails.root}/public/main_squares/#{project_name(i)}/#{answer.title.split(":").first.parameterize}/*.jpg"].sort
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
          answer.images << build_image(image)
        end
      end
    end

    def add_documents_for(poll, i)
      poll.questions.map(&:question_answers).flatten.each do |answer|
        documents(answer, i).each do |document|
  puts document
          answer.documents << build_document(document)
        end
      end
    end

    def build_document(path)
      return false unless path
      filename = path.split("/").last
      Document.new(attachment: File.new(path, "r"), title: config["title_for_document"][filename.downcase] || "unavailable", user: User.first)
    end

    def documents(answer, i)
      Dir["#{Rails.root}/public/main_squares/#{project_name(i)}/#{answer.title.split(":").first.parameterize}/*.pdf"].sort
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

  desc "Create Poll Question Answer for each Poll Question still with valid_answers values"
    task migrate_poll_question_valid_answers: :environment do
      Poll::Question.find_each do |question|
        valid_answers = question.valid_answers&.try(:split, ',')
        next unless valid_answers.present?
        valid_answers.each do |valid_answer|
          Poll::Question::Answer.create(question: question, title: valid_answer, description: '')
        end
      end
    end

end
