class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  scope :for_merchant, ->(merchant_id) { where(merchant_id: merchant_id) }

  def find_single_item_invoices
    invoices
      .joins(:invoice_items)
      .group(:id)
      .having("count(invoice_items.id) = 1")
  end
end