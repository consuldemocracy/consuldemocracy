class LegislationCommentsMigration

  def initialize
  end

  def old_debates
    return [Debate.first.id] if Rails.env.development?
    debates_and_questions.collect {|debate_id, question_id| debate_id }
  end

  def new_questions
    return [Legislation::Question.first.id] if Rails.env.development?
    debates_and_questions.collect {|debate_id, question_id| question_id }
  end

  def question_for(debate)
    new_questions[old_debates.index(debate)]
  end

  def debate_for(question)
    old_debates[new_questions.index(question)]
  end

  def migrate_data
    old_debates.each do |debate_id|
      question_id = question_for(debate_id)

      question = Legislation::Question.find(question_id)
      debate = Debate.find(debate_id)

      migrate_comments(debate, question)
    end
  end

  def undo_migrate_data
    new_questions.each do |question_id|
      debate_id = debate_for(question_id)

      question = Legislation::Question.find(question_id)
      debate = Debate.find(debate_id)

      migrate_comments(question, debate)
    end
  end

  def migrate_comments(origin, destination)
    destination.comments = origin.comments

    reset_comment_counters(origin)
    reset_comment_counters(destination)
  end

  def reset_comment_counters(origin)
    origin.class.reset_counters(origin.id, :comments)
  end

  def seed_data
    return unless Rails.env.development?

    debate = Debate.find_or_initialize_by(author: User.first,
                                          title: "Old debate to me migrated",
                                          description: "hey there how are you")
    debate.terms_of_service = "1"
    debate.save!

    debate.comments.map(&:really_destroy!)

    first_comment = Comment.create!(user: User.all.sample,
                                    commentable: debate,
                                    body: "[First Debate] First comment")

    second_comment = Comment.create!(user: User.all.sample,
                                     commentable: debate,
                                     body: "[First Debate] Second comment")

    first_reply = Comment.create!(user: User.all.sample,
                                  commentable: debate,
                                  body: "[First Debate] first reply",
                                  parent: first_comment)

    second_reply = Comment.create!(user: User.all.sample,
                                  commentable: debate,
                                  body: "[First Debate] second reply",
                                  parent: first_reply)

    Debate.reset_counters(debate.id, :comments)

    process = Legislation::Process.find_or_create_by!(title: "New process",
                                                      description: "hey there how are you",
                                                      summary: "hey there how are you",
                                                      start_date: Date.current - 7.days,
                                                      end_date: Date.current + 7.days,
                                                      debate_start_date: Date.current - 7.days,
                                                      debate_end_date: Date.current + 7.days,
                                                      debate_phase_enabled: true,
                                                      published: true)

    question = Legislation::Question.find_or_create_by!(title: "New question to copy comments",
                                                        process: process)
    question.comments.map(&:really_destroy!)
    Legislation::Question.reset_counters(question.id, :comments)
  end

  def debates_and_questions
    [
     [4865,   183],
     [4866,   184],
     [4867,   185],
     [4868,   186],
     [4869,   187],
     [4870,   188],

     [4847,   189],
     [4848,   190],
     [4849,   191],
     [4850,   192],
     [4851,   193],

     [4899,   194],
     [4900,   195],
     [4901,   196],

     [4943,   197],
     [4944,   198],

     [4880,   199],
     [4881,   200],
     [4882,   201],
     [4883,   202],
     [4884,   203],
     [4885,   204],
     [4886,   205],
     [4887,   206],
     [4888,   207],
     [4889,   208],
     [4890,   209],
     [4891,   210],
     [4892,   211],
     [4893,   212],

     [5004,   213],
     [5005,   214],
     [5006,   215],
     [5007,   216],

     [5010,   217],
     [5011,   218],
     [5012,   219],
     [5013,   220],
     [5014,   221],
     [5015,   222],
     [5016,   223],

     [5083,   224],
     [5084,   225],
     [5085,   226],
     [5086,   227],
     [5087,   228],
     [5088,   229],
     [5089,   230],
     [5090,   231],

     [5140,   232],
     [5141,   233],

     [5142,   234],
     [5143,   235],

     [5133,   236],
     [5134,   237],
     [5135,   238],
     [5136,   239],

     [5165,   240],
     [5166,   241],
     [5167,   242],
     [5168,   243]
    ]
  end

end
