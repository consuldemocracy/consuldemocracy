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
      Medida.new do |t|
        t.ID =r[0]
        t.title =r[1]
        t.description=r[2]+r[3]+r[4]
        t.author_id
        t.created_at
        t.updated_at
        t.visit_id
        t.hidden_at
        t.flags_count
        t.ignored_flag_at
        t.cached_votes_total
        t.cached_votes_up
        t.cached_votes_down
        t.comments_count
        t.confirmed_hide_at
        t.cached_anonymous_votes_total
        t.cached_votes_score
        t.hot_score
        t.confidence_score
      end .save!
      progress.inc
    end
  end
end
