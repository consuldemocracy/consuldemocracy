class Stat < ApplicationRecord
  validates :namespace, presence: true
  validates :group, presence: true
  validates :name, presence: true, uniqueness: { scope: [:namespace, :group] }

  scope :by_namespace, -> (ns) { where(namespace: ns)}
  scope :by_group,     -> (gr) { where(group: gr) }
  scope :by_namespace_group, -> (ns, gr) { by_namespace(ns).by_group(gr) }

  def set_value(v)
    self.value = v
    save!
  end

  def self.set(namespace, group, name, value)
    stat = Stat.named(namespace, group, name)
    stat.value = value
    stat.save!
    value
  end

  def self.named(namespace, group, name)
    by_namespace_group(namespace, group).where(name: name).first || new(namespace: namespace, group: group, name: name)
  end

  def self.hash(namespace)
    hash_stats = {}
    stats = by_namespace(namespace).group_by(&:group)
    stats.each_pair do |key, values|
      hash_stats[key] = values.group_by(&:name)
      hash_stats[key].each_pair do |k, v|
        hash_stats[key][k] = v.first.value
      end
    end
    hash_stats
  end
end
