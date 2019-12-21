require "csv"

namespace :db do
  desc "Import data from the CSV files"
  task alan_turing: :environment do
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
                                  terms_of_service: "1",
                                  erased_at: Time.current)
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

    puts "Creating Tags"
    csv_file = "lib/tasks/alan_turing/tags.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      attributes = line.to_hash
      attributes["id"] = attributes["id"].to_i
      ids = [4995, 6473, 6488, 6509, 7258, 7259, 7262, 7263, 7276]
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

    puts "Asigning Tags to Proposals"
    ids = {
      "4995" => "3046",
      "6473" => "93",
      "6488" => "1988",
      "6509" => "113",
      "7258" => "3990",
      "7259" => "111",
      "7262" => "1509",
      "7263" => "148",
      "7276" => "6659"
    }
    csv_file = "lib/tasks/alan_turing/tagging.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: true) do |line|
      unless line.to_hash["tag_id"].to_i == 6622 # it's a tag without name
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
  end
end
