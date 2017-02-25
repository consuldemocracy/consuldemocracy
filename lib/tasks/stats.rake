namespace :stats do

  desc "Calculate stats for the February 2017 polls"
  task polls_2017: :environment do
    poll_ids = polls_2017_ids
    polls_query = ::Poll::Voter.where(poll_id: poll_ids)

    namespace = "polls_2017_age"
    all_ages_total = 0
    ::Poll::AGE_STEPS.each_with_index do |age, i|
      next_age = ::Poll::AGE_STEPS[i+1]
      age_total = 0
      ::Poll::Voter::VALID_ORIGINS.each do |origin|
        age_query = polls_query.where(origin: origin).where("age >= ?", age)
        age_query = age_query.where("age <= ?", next_age - 1) if next_age.present?
        age_origin = age_query.select(:user_id).distinct.count
        age_total += age_origin
        Stat.named(namespace, "#{age}", origin).set_value age_origin
      end
      all_ages_total += age_total
      Stat.named(namespace, "#{age}", 'total').set_value age_total
    end
    Stat.named(namespace, "all", 'total').set_value all_ages_total

    namespace = "polls_2017_gender"
    all_genders_total = 0
    ['male', 'female'].each do |gender|
      gender_total = 0
      ::Poll::Voter::VALID_ORIGINS.each do |origin|
        gender_query = polls_query.where(origin: origin).where(gender: gender)
        gender_origin = gender_query.select(:user_id).distinct.count
        gender_total += gender_origin
        Stat.named(namespace, "#{gender}", origin).set_value gender_origin
      end
      all_genders_total += gender_total
      Stat.named(namespace, "#{gender}", 'total').set_value gender_total
    end
    Stat.named(namespace, "all", 'total').set_value all_genders_total

    namespace = "polls_2017_district"
    all_district_total = 0
    Geozone.pluck(:id).each do |geozone_id|
      district_total = 0
      ::Poll::Voter::VALID_ORIGINS.each do |origin|
        district_query = polls_query.where(origin: origin).where(geozone_id: geozone_id)
        district_origin = district_query.select(:user_id).distinct.count
        district_total += district_origin
        Stat.named(namespace, "#{geozone_id}", origin).set_value district_origin
      end
      all_genders_total += district_total
      Stat.named(namespace, "#{geozone_id}", 'total').set_value district_total
    end
    Stat.named(namespace, "all", 'total').set_value all_district_total
  end

  def polls_2017_ids
    ids = []
    ids << ::Poll.where("name ILIKE ?", "%Billete único%").pluck(:id)
    ids << ::Poll.where("name ILIKE ?", "%Gran Vía%").first
    ids << ::Poll.where("name ILIKE ?", "%Territorial de Barajas%").first
    ids << ::Poll.where("name ILIKE ?", "%Territorial de San Blas%").first
    ids << ::Poll.where("name ILIKE ?", "%Hortaleza%").first
    ids << ::Poll.where("name ILIKE ?", "%culturales en Retiro%").first
    ids << ::Poll.where("name ILIKE ?", "%Distrito de Salamanca%").first
    ids << ::Poll.where("name ILIKE ?", "%Distrito de Vicálvaro%").first
    ids.flatten
  end
end
