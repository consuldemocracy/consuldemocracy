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
  task :importacion => :environment do

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
  end
end
