require_dependency "poll/answer"
require_dependency "poll/question/answer"

section "Creating polls" do
  Poll.create!(name: I18n.t("seeds.polls.current_poll"),
               slug: I18n.t("seeds.polls.current_poll").parameterize,
               starts_at: 7.days.ago,
               ends_at:   7.days.from_now,
               geozone_restricted: false)

  Poll.create!(name: I18n.t("seeds.polls.current_poll_geozone_restricted"),
               slug: I18n.t("seeds.polls.current_poll_geozone_restricted").parameterize,
               starts_at: 5.days.ago,
               ends_at:   5.days.from_now,
               geozone_restricted: true,
               geozones: Geozone.sample(3))

  Poll.create!(name: I18n.t("seeds.polls.recounting_poll"),
               slug: I18n.t("seeds.polls.recounting_poll").parameterize,
               starts_at: 15.days.ago,
               ends_at:   2.days.ago)

  Poll.create!(name: I18n.t("seeds.polls.expired_poll_without_stats"),
               slug: I18n.t("seeds.polls.expired_poll_without_stats").parameterize,
               starts_at: 2.months.ago,
               ends_at:   1.month.ago)

  Poll.create!(name: I18n.t("seeds.polls.expired_poll_with_stats"),
               slug: I18n.t("seeds.polls.expired_poll_with_stats").parameterize,
               starts_at: 2.months.ago,
               ends_at:   1.month.ago,
               results_enabled: true,
               stats_enabled: true)

  Poll.find_each do |poll|
    name = poll.name
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        poll.name = "#{name} (#{locale})"
        poll.summary = "Summary for locale #{locale}"
        poll.description = "Description for locale #{locale}"
      end
    end
    poll.save!
  end
end

section "Creating Poll Questions & Answers" do
  Poll.find_each do |poll|
    (1..4).to_a.sample.times do
      question_title = Faker::Lorem.sentence(word_count: 3).truncate(60) + "?"
      question = Poll::Question.new(author: User.all.sample,
                                    title: question_title,
                                    poll: poll)
      I18n.available_locales.map do |locale|
        Globalize.with_locale(locale) do
          question.title = "#{question_title} (#{locale})"
        end
      end
      question.save!
      Faker::Lorem.words(number: (2..4).to_a.sample).each_with_index do |title, index|
        description = "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>"
        answer = Poll::Question::Answer.new(question: question,
                                            title: title.capitalize,
                                            description: description,
                                            given_order: index + 1)
        I18n.available_locales.map do |locale|
          Globalize.with_locale(locale) do
            answer.title = "#{title} (#{locale})"
            answer.description = "#{description} (#{locale})"
          end
        end
        answer.save!
      end
    end
  end
end

section "Creating Poll Booths & BoothAssignments" do
  20.times do |i|
    Poll::Booth.create(name: "Booth #{i}",
                       location: Faker::Address.street_address,
                       polls: [Poll.all.sample])
  end
end

section "Creating Poll Shifts for Poll Officers" do
  Poll.find_each do |poll|
    Poll::BoothAssignment.where(poll: poll).each do |booth_assignment|
      scrutiny = (poll.ends_at.to_datetime..poll.ends_at.to_datetime + Poll::RECOUNT_DURATION)
      Poll::Officer.find_each do |poll_officer|
        {
          vote_collection: (poll.starts_at.to_datetime..poll.ends_at.to_datetime),
          recount_scrutiny: scrutiny
        }.each do |task_name, task_dates|
          task_dates.each do |shift_date|
            Poll::Shift.create(booth: booth_assignment.booth,
                               officer: poll_officer,
                               date: shift_date,
                               officer_name: poll_officer.name,
                               officer_email: poll_officer.email,
                               task: task_name)
          end
        end
      end
    end
  end
end

section "Commenting Polls" do
  30.times do
    author = User.all.sample
    poll = Poll.all.sample
    Comment.create!(user: author,
                    created_at: rand(poll.created_at..Time.current),
                    commentable: poll,
                    body: Faker::Lorem.sentence)
  end
end

section "Creating Poll Voters" do
  def vote_poll_on_booth(user, poll)
    officer = Poll::Officer.all.sample

    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: "booth",
                        officer: officer,
                        officer_assignment: officer.officer_assignments.sample,
                        booth_assignment: poll.booth_assignments.sample)
  end

  def vote_poll_on_web(user, poll)
    randomly_answer_questions(poll, user)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: "web",
                        token: SecureRandom.hex(32))
  end

  def randomly_answer_questions(poll, user)
    poll.questions.each do |question|
      next unless [true, false].sample

      Poll::Answer.create!(question_id: question.id,
                           author: user,
                           answer: question.question_answers.sample.title)
    end
  end

  (Poll.expired + Poll.current + Poll.recounting).uniq.each do |poll|
    verified_users = User.level_two_or_three_verified
    if poll.geozone_restricted?
      verified_users = verified_users.where(geozone_id: poll.geozone_ids)
    end
    user_groups = verified_users.in_groups(2)
    user_groups.first.each { |user| vote_poll_on_booth(user, poll) }
    user_groups.second.compact.each { |user| vote_poll_on_web(user, poll) }
  end
end

section "Creating Poll Recounts" do
  Poll.find_each do |poll|
    poll.booth_assignments.each do |booth_assignment|
      officer_assignment = poll.officer_assignments.first
      author = Poll::Officer.first.user

      total_amount = white_amount = null_amount = 0

      booth_assignment.voters.count.times do
        case rand
        when 0...0.1 then null_amount += 1
        when 0.1...0.2 then white_amount += 1
        else total_amount += 1
        end
      end

      Poll::Recount.create!(officer_assignment: officer_assignment,
                            booth_assignment: booth_assignment,
                            author: author,
                            date: poll.ends_at,
                            white_amount: white_amount,
                            null_amount: null_amount,
                            total_amount: total_amount,
                            origin: "booth")
    end
  end
end

section "Creating Poll Results" do
  Poll.find_each do |poll|
    poll.booth_assignments.each do |booth_assignment|
      officer_assignment = poll.officer_assignments.first
      author = Poll::Officer.first.user

      poll.questions.each do |question|
        question.question_answers.each do |answer|
          Poll::PartialResult.create!(officer_assignment: officer_assignment,
                                      booth_assignment: booth_assignment,
                                      date: Date.current,
                                      question: question,
                                      answer: answer.title,
                                      author: author,
                                      amount: rand(999),
                                      origin: "booth")
        end
      end
    end
  end
end

section "Creating Poll Questions from Proposals" do
  3.times do
    proposal = Proposal.all.sample
    poll = Poll.current.first
    question = Poll::Question.new(poll: poll)
    question.copy_attributes_from_proposal(proposal)
    question_title = question.title
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        question.title = "#{question_title} (#{locale})"
      end
    end
    question.save!
    Faker::Lorem.words(number: (2..4).to_a.sample).each_with_index do |title, index|
      description = "<p>#{Faker::ChuckNorris.fact}</p>"
      answer = Poll::Question::Answer.new(question: question,
                                          title: title.capitalize,
                                          description: description,
                                          given_order: index + 1)
      I18n.available_locales.map do |locale|
        Globalize.with_locale(locale) do
          answer.title = "#{title} (#{locale})"
          answer.description = "#{description} (#{locale})"
        end
      end
      answer.save!
    end
  end
end

section "Creating Successful Proposals" do
  10.times do
    proposal = Proposal.all.sample
    poll = Poll.current.first
    question = Poll::Question.new(poll: poll)
    question.copy_attributes_from_proposal(proposal)
    question_title = question.title
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        question.title = "#{question_title} (#{locale})"
      end
    end
    question.save!
    Faker::Lorem.words(number: (2..4).to_a.sample).each_with_index do |title, index|
      description = "<p>#{Faker::ChuckNorris.fact}</p>"
      answer = Poll::Question::Answer.new(question: question,
                                          title: title.capitalize,
                                          description: description,
                                          given_order: index + 1)
      I18n.available_locales.map do |locale|
        Globalize.with_locale(locale) do
          answer.title = "#{title} (#{locale})"
          answer.description = "#{description} (#{locale})"
        end
      end
      answer.save!
    end
  end
end
