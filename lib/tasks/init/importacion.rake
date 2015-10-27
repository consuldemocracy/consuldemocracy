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

  desc "[init] Cargar datos de medidass"
  task :importacion => :environment do

    progress = RakeProgressbar.new(%x(cat lib/tasks/init/importacion/* | wc -l).to_i + 1)

    #Medida.delete_all
    xlsx= Roo::Spreadsheet.open('programa.xlsx')
    xlsxs.sheet(0).each_row(offset: 1) do |row|
      Medida.new do |m|
        m.id = row[0].to_i
        m.nombre_oficial = row[-1]
        m.slug = row[-1].to_slug
      end .save!
      progress.inc
    end
  end
end
