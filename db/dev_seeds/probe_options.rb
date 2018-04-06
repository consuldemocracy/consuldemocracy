section "Creating Probe and ProbeOptions for Town Planning project" do
  town_planning = Probe.create(codename: "town_planning")
  town_planning_options = [
    ["Balle Malle Hupe und Artur", "003"],
    ["Delta", "022"],
    ["Mas Madrid", "025"],
    ["MADBENCH", "033"],
    ["Yo tenía tres sillas en mi casa...", "036"],
    ["Sedere", "040"],
    ["TAKETE", "048"],
    ["Mucho gusto Madrid", "054"],
    ["SIENTAMADRID!", "084"],
    ["ARCO", "130"],
    ["a_park_ando", "149"],
    ["Benditas costumbres", "174"]
  ]

  town_planning_options.each do |name, code|
    ProbeOption.create(probe_id: town_planning.id, name: name, code: code)
  end
end

section "Creating Probe and ProbeOptions for Plaza de España project" do
  plaza = Probe.create(codename: "plaza")
  plaza_options = [
    ["MÁS O MENOS", "01"],
    ["PARKIN", "02"],
    ["Mi rincón favorito de Madrid", "03"],
    ["Espacio España", "04"],
    ["La pluma es la lengua del alma", "05"],
    ["CONECTOR URBANO PLAZA ESPAÑA", "06"],
    ["117....142", "07"],
    ["Baile a orillas del Manzanares", "08"],
    ["Sentiré su frescor en mis plantas", "09"],
    ["UN PASEO POR LA CORNISA", "10"],
    ["QUIERO ACORDARME", "11"],
    ["MADRID AIRE", "12"],
    ["Descubriendo Plaza de España", "13"],
    ["DirdamMadrid", "14"],
    ["Alla donde se cruzan los caminos", "15"],
    ["NADA CORRE PEDALEA", "16"],
    ["El sueño de Cervantes", "19"],
    ["ESplaza", "20"],
    ["En un lugar de Madrid", "21"],
    ["CodigoAbierto", "22"],
    ["CampoCampo", "23"],
    ["El diablo cojuelo", "26"],
    ["Metamorfosis del girasol", "27"],
    ["De este a oeste", "28"],
    ["Corredor ecologico", "29"],
    ["Welcome mother Nature", "30"],
    ["PLAZA DE ESPAÑA 2017", "31"],
    ["Ñ-AGORA", "32"],
    ["OASIS24H", "33"],
    ["Madrid wild", "34"],
    ["PlazaSdeespaña", "36"],
    ["Dentro", "37"],
    ["CON MESURA", "38"],
    ["EN BUSCA DE DULCINEA", "39"],
    ["Luces de Bohemia - Madrid Cornisa", "40"],
    ["De una plaza concéntrica a un caleidoscopio de oportunidades", "41"],
    ["Cambio de Onda", "42"],
    ["La respuesta está en el 58", "44"],
    ["En un lugar de la cornisa", "45"],
    ["Continuidad de los parques", "46"],
    ["Vamos de ronda", "47"],
    ["MADRID EM-PLAZA", "48"],
    ["230306", "49"],
    ["Redibujando la plaza", "50"],
    ["TOPOFILIA", "51"],
    ["Imprescindible, necesario, deseable", "53"],
    ["3 plazas, 2 paseos, 1 gran parque", "54"],
    ["Oz", "55"],
    ["ENCUENTRO", "56"],
    ["Generando fluorescencia con molinos ", "58"],
    ["UN REFLEJO DE LA ESPAÑA RURAL", "59"],
    ["SuperSuperficie TermosSocial", "60"],
    ["DESCUBRE MADRID", "61"],
    ["VERDECOMÚN", "62"],
    ["Ecotono urbano", "63"],
    ["LA PIEL QUE HABITO", "64"],
    ["Entreplazas.Plaza España", "66"],
    ["Abracadabra", "67"],
    ["Pradera urbana", "68"],
    ["Archipielago", "69"],
    ["Flow", "70"],
    ["EN UN LUGAR DE MADRID", "71"],
    ["1968 diluir los límites, evitar las discontinuidades y más verde", "72"],
    ["MejorANDO x Pza España", "73"],
    ["RE-VERDE CON CAUSA", "74"],
    ["ECO2Madrid", "75"],
    ["THE LONG LINE", "76"],
    ["El ojo de Horus", "77"],
    ["ME VA MADRID", "78"],
    ["THE FOOL ON THE HILL", "79"]
  ]

  plaza_options.each do |option_name, option_code|
    ProbeOption.create(probe_id: plaza.id, name: option_name, code: option_code)
  end
end

section "Commenting probe options" do
  (1..100).each do |_i|
    author = User.reorder("RANDOM()").first
    probe_option = ProbeOption.reorder("RANDOM()").first
    Comment.create!(user: author,
                    created_at: rand(probe_option.probe.created_at..Time.now),
                    commentable: probe_option,
                    body: Faker::Lorem.sentence)
  end
end
