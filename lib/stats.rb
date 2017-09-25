


def total_votes_for_answer(question, answer, ba)
  ::Poll::PartialResult.where(question_id: question.id).where(answer: answer).
  where(booth_assignment: ba).sum(:amount)
end

poll = Poll.find(1)


booth_results = []

poll.booth_assignments.each do |ba|
  response_in_booth = []
  recount = Poll::TotalResult.where(booth_assignment_id: ba.id).sum(:amount)
  whites = Poll::WhiteResult.where(booth_assignment_id: ba.id).sum(:amount)
  nulls = Poll::NullResult.where(booth_assignment_id: ba.id).sum(:amount)
  wn = whites+nulls

  poll.questions.order(id: :asc).each do |question|
    answers_to_question = ::Poll::PartialResult.where(question_id: question.id).where(booth_assignment: ba).sum(:amount)
    response_in_booth << (answers_to_question)
  end

  booth_results << [ba.booth.name => {respuestas: response_in_booth, blancos: whites, nulos: nulls, recuento_final: recount}]
end

pp booth_results
poll.questions.order(id: :asc).map(&:title)


*********************************************************


#alternativa al bucle sumando cada respuesta independientemente
  poll.questions.order(id: :asc).each do |question|
    answers_to_question = 0

    question.valid_answers.each do |answer|
      answers_to_question += ::Poll::PartialResult.where(question_id: question.id).where(answer: answer).where(booth_assignment: ba).sum(:amount)
    end
    response_in_booth << (answers_to_question + wn)
  end

****************************************************

#SOLO PARA CIERTAS URNAS
booth_ids = []
booths = Poll::Booth.find booth_ids

booth_results = []

booths.each do |b|
  b.booth_assignments.each do |ba|
    response_in_booth = []
    recount = Poll::TotalResult.where(booth_assignment_id: ba.id).sum(:amount)
    whites = Poll::WhiteResult.where(booth_assignment_id: ba.id).sum(:amount)
    nulls = Poll::NullResult.where(booth_assignment_id: ba.id).sum(:amount)

    ba.poll.questions.order(id: :asc).each do |question|
      answers_to_question = ::Poll::PartialResult.where(question_id: question.id).where(booth_assignment: ba).sum(:amount)
      response_in_booth << (answers_to_question)
    end

    booth_results << [ba.booth.name => {votacion: ba.poll.name, respuestas: response_in_booth, blancos: whites, nulos: nulls, recuento_final: recount}]
  end
end

pp booth_results

****************************************************
#SOLO ACTIVIDAD DE CIERTAS URNAS

booth_ids = [7, 148, 42, 58, 62, 68, 77, 97, 129, 130, 131, 132, 133]
booths = Poll::Booth.find booth_ids

booth_results = []

booths.each do |b|
  b.booth_assignments.each do |ba|

    results = ::Poll::PartialResult.where(booth_assignment: ba).count
    recounts = Poll::TotalResult.where(booth_assignment_id: ba.id).amount
    whites = Poll::WhiteResult.where(booth_assignment_id: ba.id).count
    nulls = Poll::NullResult.where(booth_assignment_id: ba.id).count

    booth_results << [ba.booth.name => {votacion: ba.poll_id, resultados: results, blancos: whites, nulos: nulls, recuentos_finales: recounts}]
  end
end

pp booth_results

****************************************************


****************************************************




def district_population
  {"CENTRO"              => 132644,
   "ARGANZUELA"          => 151520,
   "RETIRO"              => 118559,
   "SALAMANCA"           => 143244,
   "CHAMARTIN"           => 142610,
   "TETUAN"              => 152545,
   "CHAMBERI"            => 137532,
   "FUENCARRAL-EL PARDO" => 235482,
   "MONCLOA-ARAVACA"     => 116689,
   "LATINA"              => 234015,
   "CARABANCHEL"         => 242000,
   "USERA"               => 134015,
   "PUENTE DE VALLECAS"  => 227195,
   "MORATALAZ"           =>  94607,
   "CIUDAD LINEAL"       => 212431,
   "HORTALEZA"           => 177738,
   "VILLAVERDE"          => 141442,
   "VILLA DE VALLECAS"   => 102140,
   "VICALVARO"           =>  69800,
   "SAN BLAS-CANILLEJAS" => 153411,
   "BARAJAS"             =>  46264}
end

***********************************************
^^^^^^^^^ PRESUS PARTICIPATIVOS ^^^^^^^^^^^^^^^
* * * * * * * * * * * * * * * * * * * * * * * *
vvvvvvvvvvvvvvv PLAZA ESPAÑA vvvvvvvvvvvvvvvvvv
***********************************************

Debajo de la primera sección con el número de propuestas,
tiene que ir también en grande el número de apoyos.

En participación por sexo y por grupos de edad hay que dar el dato total sumado
considerando que participación es haber hecho una propuesta o apoyado una. Sin diferenciar.

La primera fila de edad la cambias por Menor de 19 años.

En participación por distritos cuatro columnas:
a) número de propuestas,
b) número de apoyos,
c) % participación total (considerando como arriba participantes a los que lo hagan en uno u otro), y
d) % participación distrito.

Y faltaría una fila que es Toda la Ciudad.

En toda esta última tabla consideramos distrito como el catalogado en la propuesta hecha o apoyada,
no el distrito de padrón de uno.

####################################################################################

def age(dob)
  now = Time.now.utc.to_date
  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
end

def age_group(dob)
  user_age = age(dob)

  if (0..19).include?(user_age)
    "Menor de 19 años"
  elsif (20..24).include?(user_age)
    "De 20 a 24 años"
  elsif (25..29).include?(user_age)
    "De 25 a 29 años"
  elsif (30..34).include?(user_age)
    "De 30 a 34 años"
  elsif (35..39).include?(user_age)
    "De 35 a 39 años"
  elsif (40..44).include?(user_age)
    "De 40 a 44 años"
  elsif (45..49).include?(user_age)
    "De 45 a 49 años"
  elsif (50..54).include?(user_age)
    "De 50 a 54 años"
  elsif (55..59).include?(user_age)
    "De 55 a 59 años"
  elsif (60..64).include?(user_age)
    "De 60 a 64 años"
  elsif (65..69).include?(user_age)
    "De 65 a 69 años"
  elsif (70..120).include?(user_age)
    "De 70 y más años"
  else
    puts "Cannot determine age group for dob: #{dob} and age: #{age(dob)}"
    "Unknown"
  end
end

def district_population
  {"CENTRO" => 132684,
   "ARGANZUELA" => 152034,
   "RETIRO" => 118892,
   "SALAMANCA" => 143728,
   "CHAMARTIN" => 142998,
   "TETUAN" => 153113,
   "CHAMBERI" => 137845,
   "FUENCARRAL-EL PARDO" => 236299,
   "MONCLOA-ARAVACA" => 116889,
   "LATINA" => 234479,
   "CARABANCHEL" => 242997,
   "USERA" => 134425,
   "PUENTE DE VALLECAS" => 227661,
   "MORATALAZ" => 94698,
   "CIUDAD LINEAL" => 212901,
   "HORTALEZA" => 178692,
   "VILLAVERDE" => 141880,
   "VILLA DE VALLECAS" => 102692,
   "VICALVARO" => 69862,
   "SAN BLAS-CANILLEJAS" => 153859,
   "BARAJAS" => 46536}
end

####################################################################################


ids_usuarios_participantes = []
  # los autores de propuestas
  SpendingProposal.find_each {|sp| ids_usuarios_participantes << sp.author_id}
  # los votantes
  User.select(:id).where("district_wide_spending_proposals_supported_count < ? OR city_wide_spending_proposals_supported_count < ?", 10, 10).find_each {|u| ids_usuarios_participantes << u.id}
ids_usuarios_participantes = ids_usuarios_participantes.compact.uniq.sort

participación_total = ids_usuarios_participantes.size

# Participación por sexo/edad
hombre = 0
mujer = 0
por_edad = Hash.new(0)
por_distrito = Hash.new(0)

geozone_names = {}
Geozone.find_each do |g|
  geozone_names[g.id] = g.name
end

User.where(id: ids_usuarios_participantes).find_each do |user|
  # por sexo:
  if user.gender == 'male'
    hombre +=1
  elsif user.gender == 'female'
    mujer += 1
  end

  # por edad:
  por_edad[age_group(user.date_of_birth)] += 1 if user.date_of_birth.present?

  # por distrito:
  if user.district_wide_spending_proposals_supported_count < 10
    por_distrito["Toda la ciudad"] += 1
  end
  if user.city_wide_spending_proposals_supported_count < 10
    por_distrito[geozone_names[user.supported_spending_proposals_geozone_id]] += 1
  end
end

# Participacion por distrito
propuestas_por_distrito = Hash.new(0)
apoyos_por_distrito = Hash.new(0)
SpendingProposal.includes(:geozone).find_each do |sp|
  if sp.geozone_id.blank?
    propuestas_por_distrito["Toda la ciudad"] += 1
    apoyos_por_distrito["Toda la ciudad"] += sp.total_votes
  else
    propuestas_por_distrito[sp.geozone.name] += 1
    apoyos_por_distrito[sp.geozone.name] += sp.total_votes
  end
end

# % de participacion por distrito: propuestas_por_distrito/numero_de_propuestas
# % de apoyos por distrito:        apoyos_por_distrito/numero_de_apoyos_totales
# participación por distrito:      por_distrito/participación_total
# por población de distrito:       por_distrito/district_population


numero_de_propuestas = SpendingProposal.count
numero_de_propuestas_viables = SpendingProposal.not_unfeasible.count
numero_de_propuestas_no_viables = SpendingProposal.unfeasible.count

numero_de_apoyos_totales = Vote.where(votable_type: 'SpendingProposal').count


####################################################################################
numero_de_propuestas                   n
numero_de_propuestas_viables           n
numero_de_propuestas_no_viables        n
numero_de_apoyos_totales               n

participación_total                    n

propuestas_por_distrito                {}
apoyos_por_distrito                    {}

hombre                                 n
mujer                                  n
por_edad                               {}
por_distrito                           {}

####################################################################################

16 abril 2016 00:00:00
Personas que han participado (crear o apoyar propuesta): 23825
Número total de apoyos: 168811

Propuestas: 5072 (3603 válidas + 1445 inviables + 24 retiradas/eliminadas)



####################################################################################


bad_users_id = [43, 153, 487, 568, 574, 590, 1084, 1092, 1429, 4333, 7660, 8121, 9083, 9444, 9795, 10293, 10684, 11117, 11780, 13101, 15504, 20541, 22455, 22551, 24917, 26829, 29430, 30304, 31244, 31778, 34922, 36430, 59896, 64742, 68549, 90346, 106844, 107137, 113875, 114029, 115593, 116569, 122150, 124156, 124362, 125193, 125742, 126984, 127167, 128556, 134463]

bad_users_id.each do |user_id|
  user = User.find(user_id)
  votos = user.votes.where(votable_type: 'SpendingProposal').includes(:votable).order(:created_at)

  de_distrito=[]
  distritos = []
  de_ciudad = []

  votos.each do |voto|
    if voto.votable.geozone_id.blank?
      de_ciudad << voto
    else
      de_distrito << voto
      distritos << voto.votable.geozone_id
    end
  end
  puts "****************************************\n" +
       "   Informe Usuario #{user.id} \n" +
       "   Votos de ciudad: #{de_ciudad.size}\n" +
       "   Votos de distrito: #{de_distrito.size}\n" +
       "   Distritos: #{distritos.uniq}\n" +
       "****************************************\n"

  if de_ciudad.size > 10
    borrar_n = de_ciudad.size - 10
    votos_ciudad_a_borrar = de_ciudad.last(borrar_n)
    votos_ciudad_a_borrar.each do |voto_ciudad_a_borrar|
      sp = voto_ciudad_a_borrar.votable
      voto_ciudad_a_borrar.destroy
      sp.update_cached_votes
    end
  end

  del_primer_distrito = []
  if distritos.size > 1
    distritos_a_borrar = distritos - [distritos.first]
    de_distrito.each do |voto_de_distrito|
      if distritos_a_borrar.include?(voto_de_distrito.votable.geozone_id)
        sp = voto_de_distrito.votable
        voto_de_distrito.destroy
        sp.update_cached_votes
      else
        del_primer_distrito << voto_de_distrito
      end
    end
  else
    del_primer_distrito = de_distrito
  end

  if del_primer_distrito.size > 10
    borrar_n = del_primer_distrito.size - 10
    votos_distrito_a_borrar = del_primer_distrito.last(borrar_n)
    votos_distrito_a_borrar.each do |voto_distrito_a_borrar|
      sp = voto_distrito_a_borrar.votable
      voto_distrito_a_borrar.destroy
      sp.update_cached_votes
    end
  end

  user.supported_spending_proposals_geozone_id = distritos.first
  user.save(validate: false)
end
