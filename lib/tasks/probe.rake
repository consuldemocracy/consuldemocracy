namespace :probes do
  desc "Create a debate for each probe option of the town planning probe"
  task plaza_debates: :environment do
    probe = Probe.where(codename: "plaza").first

    probe.probe_options.each do |probe_option|
      puts "Creating debate for probe option: #{probe_option.name}"

      title = probe_option.name
      description = "Este es uno de los proyectos presentados para la Remodelación de Plaza España, puedes participar en el proceso y votar el que más te guste en http://decidepre.madrid.es/proceso/plaza-espana."
      author = User.where(username: "Abriendo Madrid").first || User.first

      debate = Debate.where(title: title.ljust(4), description: description, author: author).first_or_initialize
      debate.terms_of_service = "1"
      debate.save!
      probe_option.update!(debate: debate)
    end
  end
end