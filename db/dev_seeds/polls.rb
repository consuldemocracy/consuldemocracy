section "Creating polls" do

  Poll.create(name: I18n.t('seeds.polls.current_poll'),
              starts_at: 7.days.ago,
              ends_at:   7.days.from_now,
              geozone_restricted: false)

  Poll.create(name: I18n.t('seeds.polls.current_poll_geozone_restricted'),
              starts_at: 5.days.ago,
              ends_at:   5.days.from_now,
              geozone_restricted: true,
              geozones: Geozone.reorder("RANDOM()").limit(3))

  Poll.create(name: I18n.t('seeds.polls.incoming_poll'),
              starts_at: 1.month.from_now,
              ends_at:   2.months.from_now)

  Poll.create(name: I18n.t('seeds.polls.recounting_poll'),
              starts_at: 15.days.ago,
              ends_at:   2.days.ago)

  Poll.create(name: I18n.t('seeds.polls.expired_poll_without_stats'),
              starts_at: 2.months.ago,
              ends_at:   1.month.ago)

  Poll.create(name: I18n.t('seeds.polls.expired_poll_with_stats'),
              starts_at: 2.months.ago,
              ends_at:   1.month.ago,
              results_enabled: true,
              stats_enabled: true)
end

section "Creating Poll Questions & Answers" do
  Poll.find_each do |poll|
    (1..4).to_a.sample.times do
      question = Poll::Question.create!(author: User.all.sample,
                                        title: Faker::Lorem.sentence(3).truncate(60) + '?',
                                        poll: poll)
      Faker::Lorem.words((2..4).to_a.sample).each do |answer|
        description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
        Poll::Question::Answer.create!(question: question,
                                       title: answer.capitalize,
                                       description: description)
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
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: 'booth',
                        officer: Poll::Officer.all.sample)
  end

  def vote_poll_on_web(user, poll)
    randomly_answer_questions(poll, user)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: 'web',
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
    level_two_verified_users = User.level_two_verified
    if poll.geozone_restricted?
      level_two_verified_users = level_two_verified_users.where(geozone_id: poll.geozone_ids)
    end
    user_groups = level_two_verified_users.in_groups(2)
    user_groups.first.each { |user| vote_poll_on_booth(user, poll) }
    user_groups.second.compact.each { |user| vote_poll_on_web(user, poll) }
  end
end

section "Creating Poll Recounts" do
  Poll.find_each do |poll|
    poll.booth_assignments.each do |booth_assignment|
      officer_assignment = poll.officer_assignments.first
      author = Poll::Officer.first.user

      Poll::Recount.create!(officer_assignment: officer_assignment,
                            booth_assignment: booth_assignment,
                            author: author,
                            date: poll.ends_at,
                            white_amount: rand(0..10),
                            null_amount: rand(0..10),
                            total_amount: rand(100..9999),
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
    question = Poll::Question.create(poll: poll)
    Faker::Lorem.words((2..4).to_a.sample).each do |answer|
      Poll::Question::Answer.create!(question: question,
                                     title: answer.capitalize,
                                     description: Faker::ChuckNorris.fact)
    end
    question.copy_attributes_from_proposal(proposal)
    question.save!
  end
end

section "Creating Successful Proposals" do
  10.times do
    proposal = Proposal.all.sample
    poll = Poll.current.first
    question = Poll::Question.create(poll: poll)
    Faker::Lorem.words((2..4).to_a.sample).each do |answer|
      Poll::Question::Answer.create!(question: question,
                                     title: answer.capitalize,
                                     description: Faker::ChuckNorris.fact)
    end
    question.copy_attributes_from_proposal(proposal)
    question.save!
  end
end
