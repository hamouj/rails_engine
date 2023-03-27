# frozen_string_literal: true

# ./app/models/customer
class Customer < ApplicationRecord
  has_many :invoices
end