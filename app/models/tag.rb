class Tag < ActsAsTaggableOn::Tag
  def self.machine_learning?
    MachineLearning.enabled? && Setting["machine_learning.tags"].present?
  end
end
