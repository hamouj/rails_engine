# frozen_string_literal: true

# ./app/models/invoice_item
class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
end