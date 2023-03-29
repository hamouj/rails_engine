class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items

  def self.find_by_name(name)
    where("merchants.name ILIKE '%#{name}%'")
    .order("lower(name)")
    .first
  end
end
