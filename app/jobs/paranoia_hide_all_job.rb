class ParanoiaHideAllJob < ActiveJob::Base
  queue_as :default

  def perform(class_to_hide, ids)
    hideable = class_to_hide.classify.constantize
    # first try with a transaction cause is x10 faster.
    # Case the transaction fails then proceed in a none atomic
    begin
      hideable.transaction do
        hideable.where(id: ids).find_each &:hide
      end
    rescue
      hideable.where(id: ids).find_each &:hide
    end
  end

end