require 'roo'

class String
  def to_slug
    #strip the string
    ret = I18n.transliterate self.strip.downcase

    #blow away apostrophes
    ret.gsub! /['`]/,""

    ret.gsub! "/","-"

    #replace all non alphanumeric, underscore or periods with underscore
    ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, ''

    #convert double underscores to single
    ret.gsub! /_+/,"_"

    #strip off leading/trailing underscore
    ret.gsub! /\A[_\.]+|[_\.]+\z/,""

    ret.downcase
  end
end

namespace :init do

  desc "[init] Cargar datos de territorios"
  task :territorios => :environment do

    progress = RakeProgressbar.new(%x(cat lib/tasks/init/territorios/* | wc -l).to_i + 1)

    TerritorioEspecial.delete_all

    TerritorioEspecial.create! id: TerritorioEspecial::ESTATAL, nombre:"Estatal", slug: "", poblacion: 46600949, superficie: 504645
    TerritorioEspecial.create! id: 2, nombre:"Unión Europea", slug: "ue", poblacion: 501105661, superficie: 4324782
    TerritorioEspecial.create! id: 3, nombre:"Exterior", slug: "exterior"

    Pais.delete_all
    CSV.foreach "lib/tasks/init/territorios/paises.csv" do |row|
      Pais.new do |p|
        p.id = row[0].to_i
        p.nombre_oficial = row[-1]
        p.slug = row[-1].to_slug
      end .save!
      progress.inc
    end

    Comunidad.delete_all
    CSV.foreach "lib/tasks/init/territorios/comunidades.csv", {:col_sep => "\t"} do |row|
      Comunidad.new do |c|
        c.id = row[0][2..-1].to_i
        nombres = row[1].split("/")
        c.nombre_oficial = nombres[0]
        c.nombre_cooficial = nombres[1]
        c.slug = row[4]
        c.poblacion = row[2].to_i
        c.superficie = row[3].to_i
      end .save!
      progress.inc
    end

    Provincia.delete_all
    capitales = {}
    CSV.foreach "lib/tasks/init/territorios/provincias.csv", {:col_sep => "\t"} do |row|
      Provincia.new do |p|
        p.id = row[0][2..-1].to_i
        p.comunidad_id = row[3][2..-1].to_i
        nombres = row[1].split("/")
        p.nombre_oficial = nombres[0]
        p.nombre_cooficial = nombres[1]
        p.slug = nombres[0].to_slug
        p.poblacion = row[5].to_i
        p.superficie = row[6].to_i
        capitales[row[2]] = p
      end .save!
      progress.inc
    end

    Isla.delete_all
    islas = {}
    CSV.foreach "lib/tasks/init/territorios/islas.tsv", {:col_sep => "\t"} do |row|
      provincia_id = row[0][2..4].to_i
      id = row[2][2..-1].to_i
      Isla.new do |i|
        i.id = id
        i.provincia_id = provincia_id
        nombres = row[3].split("/")
        i.nombre_oficial = nombres[0]
        i.nombre_cooficial = nombres[1]
        i.slug = nombres[0].to_slug
      end .save! if not islas.values.member? id
      islas[row[0]] = id
      progress.inc
    end

    Municipio.delete_all
    CSV.foreach "lib/tasks/init/territorios/municipios.csv", {:col_sep => "\t"} do |row|
      municipio = Municipio.new do |m|
        m.id = "#{row[0][2..3]}#{row[0][5..7]}#{row[0][9]}".to_i
        m.provincia_id = row[2][2..-1].to_i
        m.isla_id = islas[row[0]]
        nombres = row[1].split("/")
        m.nombre_oficial = nombres[0]
        m.nombre_cooficial = nombres[1]
        m.slug = nombres[0].to_slug
        m.poblacion = row[6].to_i
        m.superficie = row[7].to_i
        m.longitud = row[8].to_f
        m.latitud = row[9].to_f
      end

      municipio.save!
      capital = capitales[row[1]]
      municipio.capital_de = capital if capital and capital.id == municipio.provincia_id
      progress.inc
    end
  end

end
