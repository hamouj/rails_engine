class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true

  scope :for_merchant, ->(merchant_id) { where(merchant_id: merchant_id) }

  def find_single_item_invoices
    invoices
      .joins(:invoice_items)
      .group(:id)
      .having("count(invoice_items.id) = 1")
  end

  def self.find_by_name(name)
    where("items.name ILIKE '%#{name}%'")
    .order("lower(name)")
  end

  def self.find_by_min_price(price)
    where("items.unit_price >= ?", price)
    .order(:unit_price)
  end

  def self.find_by_max_price(price)
    where("items.unit_price <= ?", price)
    .order(:unit_price)
  end

  def self.find_by_min_max_price(min_price, max_price)
    where("items.unit_price between #{min_price} AND #{max_price}")
    .order(:unit_price)
  end

end