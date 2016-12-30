class API::ProposalNotification

  attr_accessor :proposal_notification

  def initialize(id)
    @proposal_notification = ::ProposalNotification.find(id)
  end

  def self.public_columns
    ["title",
     "body",
     "proposal_id",
     "created_at"]
  end

  def public?
    proposal_notification.proposal.hidden? ? false : true
  end

end


#* COMPROBAR campo "proposal_id". Si la propuesta de la que depende no está incluida públicamente por estar oculto u otra razón, no se incluirá la notificación aquí.