namespace :stats do

  desc "Calculate stats for the 11 Main Squares 2018 polls"
  task polls_2018: :environment do
    poll_ids = polls_2018_ids
    polls_query = ::Poll::Voter.where(poll_id: poll_ids)

    namespace = "polls_2018_age"
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

    namespace = "polls_2018_gender"
    all_genders_total = 0
    ['male', 'female'].each do |gender|
      gender_total = 0
      ::Poll::Voter::VALID_ORIGINS.each do |origin|
        gender_query = polls_query.where(origin: origin).where(gender: gender)
        gender_origin = gender_query.select(:user_id).distinct.count
        gender_total += gender_origin
        Stat.named(namespace, "#{gender}", origin).set_value gender_origin
      end
      Stat.named(namespace, "#{gender}", 'total').set_value gender_total
      gender_uniq_total = polls_query.where(gender: gender).select(:user_id).distinct.count
      Stat.named(namespace, "#{gender}", 'uniq_total').set_value gender_uniq_total
      all_genders_total += gender_uniq_total
    end
    Stat.named(namespace, "all", 'total').set_value all_genders_total

    namespace = "polls_2018_district"
    all_district_total = 0
    Geozone.pluck(:id).each do |geozone_id|
      district_total = 0
      ::Poll::Voter::VALID_ORIGINS.each do |origin|
        district_query = polls_query.where(origin: origin).where(geozone_id: geozone_id)
        district_origin = district_query.select(:user_id).distinct.count
        district_total += district_origin
        Stat.named(namespace, "#{geozone_id}", origin).set_value district_origin
      end
      all_district_total += district_total
      Stat.named(namespace, "#{geozone_id}", 'total').set_value district_total
    end
    Stat.named(namespace, "all", 'total').set_value all_district_total

    #namespace = "polls_2018_polls"
    #poll_ids.each do |poll_id|
    #  poll = Poll.find(poll_id)
    #  ba_ids = poll.booth_assignment_ids

    #  web = Poll::TotalResult.web.where(booth_assignment_id: ba_ids).sum(:amount)
    #  booth = Poll::TotalResult.booth.where(booth_assignment_id: ba_ids).sum(:amount)
    #  letter = Poll::TotalResult.letter.where(booth_assignment_id: ba_ids).sum(:amount)

    #  white_web = Poll::WhiteResult.web.where(booth_assignment_id: ba_ids).sum(:amount)
    #  white_booth = Poll::WhiteResult.booth.where(booth_assignment_id: ba_ids).sum(:amount)
    #  white_letter = Poll::WhiteResult.letter.where(booth_assignment_id: ba_ids).sum(:amount)

    #  null_web = Poll::NullResult.web.where(booth_assignment_id: ba_ids).sum(:amount)
    #  null_booth = Poll::NullResult.booth.where(booth_assignment_id: ba_ids).sum(:amount)
    #  null_letter = Poll::NullResult.letter.where(booth_assignment_id: ba_ids).sum(:amount)

    #  valid_web_votes = web - white_web - null_web
    #  valid_booth_votes = booth - white_booth - null_booth
    #  valid_letter_votes = letter - white_letter - null_letter

    #  Stat.named(namespace, "#{poll_id}", 'total_votes').set_value(web + booth + letter)
    #  Stat.named(namespace, "#{poll_id}", 'web_votes').set_value(valid_web_votes)
    #  Stat.named(namespace, "#{poll_id}", 'booth_votes').set_value(valid_booth_votes)
    #  Stat.named(namespace, "#{poll_id}", 'letter_votes').set_value(valid_letter_votes)
    #  Stat.named(namespace, "#{poll_id}", 'total_valid_votes').set_value(valid_web_votes + valid_booth_votes + valid_letter_votes)
    #  Stat.named(namespace, "#{poll_id}", 'white_web_votes').set_value(white_web)
    #  Stat.named(namespace, "#{poll_id}", 'white_booth_votes').set_value(white_booth)
    #  Stat.named(namespace, "#{poll_id}", 'white_letter_votes').set_value(white_letter)
    #  Stat.named(namespace, "#{poll_id}", 'total_white_votes').set_value(white_web + white_booth + white_letter)
    #  Stat.named(namespace, "#{poll_id}", 'null_web_votes').set_value(null_web)
    #  Stat.named(namespace, "#{poll_id}", 'null_booth_votes').set_value(null_booth)
    #  Stat.named(namespace, "#{poll_id}", 'null_letter_votes').set_value(null_letter)
    #  Stat.named(namespace, "#{poll_id}", 'total_null_votes').set_value(null_web + null_booth + null_letter)
    #  Stat.named(namespace, "#{poll_id}", 'total_web').set_value(web)
    #  Stat.named(namespace, "#{poll_id}", 'total_booth').set_value(booth)
    #  Stat.named(namespace, "#{poll_id}", 'total_letter').set_value(letter)
    #  Stat.named(namespace, "#{poll_id}", 'total_total').set_value(web + booth + letter)
    #end

    namespace = "polls_2018_participation"
    # total_web_votes = Poll::PartialResult.web.sum(:amount) + Poll::WhiteResult.web.sum(:amount) + Poll::NullResult.web.sum(:amount)
    # total_booth_votes = Poll::PartialResult.booth.sum(:amount) + Poll::WhiteResult.booth.sum(:amount) + Poll::NullResult.booth.sum(:amount)

    ba_ids = []
    poll_ids.each do |poll_id|
      poll = Poll.find(poll_id)
      ba_ids << poll.booth_assignment_ids
    end
    ba_ids = ba_ids.flatten

    total_web_votes = Poll::Answer.where(poll_id: poll_ids).count
    total_booth_votes = Poll::PartialResult.booth.where(booth_assignment_id: ba_ids).sum(:amount) + Poll::Recount.sum(:white_amount) + Poll::Recount.sum(:null_amount)

    Stat.named(namespace, "totals", 'participantes_totales').set_value polls_query.select(:user_id).distinct.count
    Stat.named(namespace, "totals", 'votos_totales').set_value(total_web_votes + total_booth_votes)
    Stat.named(namespace, "totals", 'votos_total_web').set_value total_web_votes
    Stat.named(namespace, "totals", 'votos_total_booth').set_value total_booth_votes
    Stat.named(namespace, "totals", 'participantes_total_web').set_value polls_query.web.select(:user_id).distinct.count
    Stat.named(namespace, "totals", 'participantes_total_booth').set_value polls_query.booth.select(:user_id).distinct.count

    namespace = "polls_2018_cache"
    Stat.named(namespace, "keys", 'stats').set_value(Stat.named(namespace, "keys", 'stats').value.to_i + 1)
  end

  def polls_2018_ids
    Poll.where(starts_at: Time.parse('08-10-2017'), ends_at: Time.parse('22-10-2017')).pluck(:id)
  end
end
