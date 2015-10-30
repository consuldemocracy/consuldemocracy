namespace :medidas do
  desc "Updates all medidas by recalculating their hot_score"
  task hot_score: :environment do
    Medida.find_in_batches do |medidas|
      medidas.each(&:save)
    end
  end

end
