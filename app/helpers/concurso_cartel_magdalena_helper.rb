module ConcursoCartelMagdalenaHelper

  def concurso_cartel_class(result)
    if params[:id].split('_').last == result
      'is-active'
    end
  end

  def calcula_resultados_cartel(votacion)
    question = votacion.questions.first
    total_vots = question.answers.size
    authors = question.answers.map(&:author)
    males = authors.select { |a| a.gender == 'male'}.size
    male_percentage = (males * 100) / total_vots
    females = authors.select { |a| a.gender == 'female'}.size
    female_percentage = (females * 100) / total_vots
    {
      total_vots: total_vots,
      cartells_seleccionats: question.valid_answers.size,
      total_male_participants: males,
      male_percentage: male_percentage,
      total_female_participants: females,
      female_percentage: female_percentage,
      age_groups: grupos_de_edad(authors)
    }

  end

  def grupos_de_edad(participants)
    groups = Hash.new(0)
    ["16 - 19",
    "20 - 24",
    "25 - 29",
    "30 - 34",
    "35 - 39",
    "40 - 44",
    "45 - 49",
    "50 - 54",
    "55 - 59",
    "60 - 64",
    "65 - 69",
    "70 - 140"].each do |group|
      start, finish = group.split(" - ")
      group_name = (group == "70 - 140" ? "+ 70" : group)
      groups[group_name] = User.where(id: participants).where("date_of_birth > ? AND date_of_birth < ?", finish.to_i.years.ago.beginning_of_year, eval(start).years.ago.end_of_year).count
    end
    groups
  end
end
