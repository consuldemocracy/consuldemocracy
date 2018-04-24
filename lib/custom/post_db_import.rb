# Script permettant de gerer les liens et elements manquant apres l'import de la BDD originelle
module PostDbImport

  def self.call!
    set_proposals_community!
  end

  private

  def self.set_proposals_community!
    Proposal.where(community_id: nil).each do |proposal|
      proposal.associate_community
      proposal.save!
    end
  end

end
