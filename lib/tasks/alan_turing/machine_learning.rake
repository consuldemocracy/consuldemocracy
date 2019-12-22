require "csv"

namespace :db do
  desc "Import data from the CSV files"
  task machine_learning_alan_turing: :environment do
    print "Adjusting Settings: "
    Setting["feature.featured_proposals"] = true
    Setting["proposal_notification_minimum_interval_in_days"] = 0
    puts "done!"

    puts "Creating Proposals"
    csv_file = "lib/tasks/alan_turing/proposals.csv"
    description_max_length = Proposal.description_max_length
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      attributes.delete("proceeding")
      attributes.delete("sub_proceeding")
      attributes["terms_of_service"] = "1"
      attributes["author_id"] = 1
      attributes["published_at"] = Time.current
      if attributes["description"].present?
        attributes["description"] = attributes["description"].truncate(description_max_length)
      end
      unless Proposal.find_by(id: attributes["id"])
        proposal = Proposal.create!(attributes)
        print "." if (proposal.id % 100) == 0
      end
    end
    puts "\nProposals created!"

    puts "Asigning Users to Proposals"
    user_deleted = User.find_by(email: "usuario_eliminado@consul.dev")
    unless user_deleted.present?
      user_deleted = User.create!(username: "Usuario eliminado",
                                  email: "usuario_eliminado@consul.dev",
                                  password: "12345678",
                                  password_confirmation: "12345678",
                                  confirmed_at: Time.current,
                                  terms_of_service: "1")
    end
    user_deleted_id = user_deleted.id

    csv_file = "lib/tasks/alan_turing/proposals-users-full.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      proposal = Proposal.find_by(id: attributes["proposal"].to_i)
      if proposal.present?
        if attributes["usernumber"].present?
          attributes["usernumber"] = attributes["usernumber"].to_i
          unless User.find_by(id: attributes["usernumber"])
            User.create!(id: attributes["usernumber"],
                       username: "usuario_#{attributes["usernumber"]}",
                       email: "usuario_#{attributes["usernumber"]}@consul.dev",
                       password: "12345678",
                       password_confirmation: "12345678",
                       confirmed_at: Time.current,
                       terms_of_service: "1")
          end
          unless proposal.author_id == attributes["usernumber"]
            proposal.update_columns(author_id: attributes["usernumber"])
            print "." if (proposal.id % 100) == 0
          end
        else
          unless proposal.author_id == user_deleted_id
            proposal.update_columns(author_id: user_deleted_id)
            print "." if (proposal.id % 100) == 0
          end
        end
      end
    end
    puts "\nUsers assigned to Proposals!"

    puts "Creating Machine Learning Tags"
    csv_file = "lib/tasks/alan_turing/ml_tags.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      attributes["id"] = attributes["id"].to_i
      ids = [106, 66, 137, 191, 118, 83, 117, 71, 122, 119, 77, 126, 182, 156, 52,
             121, 139, 96, 59, 101, 104, 53, 176, 183, 102, 57, 171, 58, 157, 152,
             56, 38, 134, 107, 146, 197, 21, 158, 180, 172]
      if attributes["name"].present?
        if attributes["name"].length >= 150
          attributes["name"] = attributes["name"].truncate(150)
        end
        unless Tag.find_by(id: attributes["id"])
          unless ids.include?(attributes["id"])
            tag = Tag.create!(attributes)
            print "." if (tag.id % 100) == 0
          end
        end
      end
    end
    puts "\nTags created!"

    puts "Asigning Machine Learning Tags to Proposals"
    ids = {
      "106" => "61",
      "66"  => "23",
      "137" => "28",
      "191" => "187",
      "118" => "92",
      "83"  => "29",
      "117" => "93",
      "71"  => "19",
      "122" => "19",
      "119" => "36",
      "77"  => "74",
      "126" => "74",
      "182" => "74",
      "156" => "108",
      "52"  => "47",
      "121" => "69",
      "139" => "131",
      "96"  => "30",
      "59"  => "13",
      "101" => "26",
      "104" => "81",
      "53"  => "46",
      "176" => "11",
      "183" => "143",
      "102" => "27",
      "57"  => "37",
      "171" => "41",
      "58"  => "39",
      "157" => "22",
      "152" => "148",
      "56"  => "1",
      "38"  => "1",
      "134" => "79",
      "107" => "91",
      "146" => "91",
      "197" => "91",
      "21"  => "4",
      "158" => "4",
      "180" => "4",
      "172" => "128"
    }
    csv_file = "lib/tasks/alan_turing/ml_tagging.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      unless line.to_hash["tag_id"].to_i == 62 || line.to_hash["tag_id"].to_i == 72 # tags without name
        attributes = line.to_hash
        attributes["tag_id"] = ids[attributes["tag_id"]] if ids[attributes["tag_id"]]
        if attributes["taggable_type"] == "Proposal"
          if attributes["tag_id"].present? && attributes["taggable_id"].present?
            attributes["tag_id"] = attributes["tag_id"].to_i
            attributes["taggable_id"] = attributes["taggable_id"].to_i
            attributes["context"] = "tags"
            unless Tagging.where(tag_id: attributes["tag_id"], taggable_id: attributes["taggable_id"]).present?
              tagging = Tagging.create!(attributes)
              print "." if (tagging.id % 100) == 0
            end
          end
        end
      end
    end
    puts "\nTags assigned to Proposals!"

    puts "Creating Comments"
    users_id = User.pluck(:id).to_a
    csv_file = "lib/tasks/alan_turing/comments.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      if attributes["commentable_type"] == "Proposal"
        attributes["user_id"] = users_id.sample
        attributes["id"] = attributes["id"].to_i
        attributes["commentable_id"] = attributes["commentable_id"].to_i
        attributes["cached_votes_total"] = attributes["cached_votes_total"].to_i
        attributes["cached_votes_up"] = attributes["cached_votes_up"].to_i
        attributes["cached_votes_down"] = attributes["cached_votes_down"].to_i
        if attributes["ancestry"].present?
          attributes["ancestry"] = attributes["ancestry"].to_i
        else
          attributes["ancestry"] = nil
        end
        attributes["confidence_score"] = attributes["confidence_score"].to_i
        attributes.delete("created_at")
        if attributes["body"].present?
          begin
            unless Comment.find_by(id: attributes["id"])
              comment = Comment.create!(attributes)
              print "." if (comment.id % 100) == 0
            end
          rescue ActsAsTaggableOn::DuplicateTagError
          end
        end
      end
    end
    puts "\nComments created!"

    puts "Creating Machine Learning Summary Comments"
    csv_file = "lib/tasks/alan_turing/ml_summary_comments.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      attributes["commentable_type"] = "Proposal"
      unless SummaryComment.find_by(id: attributes["id"])
        summary_comments = SummaryComment.create!(attributes)
        print "." if (summary_comments.id % 100) == 0
      end
    end
    puts "\nMachine Learning Summary Comments created!"

    puts "Creating Users Relations"
    csv_file = "lib/tasks/alan_turing/ml_users_related.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: false) do |line|
      list = line.to_a
      user_id = list.first
      if user_id.present?
        unless User.find_by_id(user_id)
          User.create!(id: user_id,
                       username: "usuario_#{user_id}",
                       email: "usuario_#{user_id}@consul.dev",
                       password: "12345678",
                       password_confirmation: "12345678",
                       confirmed_at: Time.current,
                       terms_of_service: "1")
        end
        list.delete(user_id)
        list.each do |related_user_id|
          if related_user_id.present?
            unless User.find_by_id(related_user_id)
              User.create!(id: related_user_id,
                           username: "usuario_#{related_user_id}",
                           email: "usuario_#{related_user_id}@consul.dev",
                           password: "12345678",
                           password_confirmation: "12345678",
                           confirmed_at: Time.current,
                           terms_of_service: "1")
            end
            unless RelatedUser.exists?(user_id, related_user_id)
              related_user = RelatedUser.create!(user_id: user_id, related_user_id: related_user_id)
              print "." if (related_user.id % 100) == 0
            end
          end
        end
      end
    end
    puts "\nUsers Relations created!"

    puts "Asigning Related Content to Proposals"
    csv_file = "lib/tasks/alan_turing/ml_related_proposals.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: false) do |line|
      list = line.to_a
      proposal_id = list.first
      list.delete(proposal_id)
      list.each do |related_proposal_id|
        if related_proposal_id.present?
          unless RelatedContent.exists?(parent_relationable_id: proposal_id,
                                        child_relationable_id: related_proposal_id)
            related_content = RelatedContent.create!(parent_relationable_id: proposal_id,
                                                      parent_relationable_type: "Proposal",
                                                      child_relationable_id: related_proposal_id,
                                                      child_relationable_type: "Proposal",
                                                      author_id: 1)
            print "." if (related_content.id % 100) == 0
          end
        end
      end
    end
    puts "\nRelated content assigned to Proposals!"

    puts "Asigning Users to Comments"
    user_erased = User.create!(username: "Usuario eliminado",
                                email: "usuario_borrado@consul.dev",
                                password: "12345678",
                                password_confirmation: "12345678",
                                confirmed_at: Time.current,
                                terms_of_service: "1",
                                erased_at: Time.current)

    csv_file = "lib/tasks/alan_turing/comments_with_users.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      comment = Comment.find_by(id: attributes["comment"].to_i)
      if comment.present?
        if attributes["usernumber"].present?
          unless comment.user_id == attributes["usernumber"]
            comment.update_columns(user_id: attributes["usernumber"])
          end
        else
          comment.update_columns(user_id: user_erased.id)
        end
        print "." if (comment.id % 100) == 0
      end
    end
    puts "\nUsers assigned to Comments!"

    puts "Recalculating Proposal's Comments"
    Proposal.find_each do |proposal|
      comments_number = Comment.where(commentable_id: proposal.id).count
      proposal.update_columns(comments_count: comments_number)
      print "." if (proposal.id % 100) == 0
    end
    puts "\nComments recalculated!"
  end
end
