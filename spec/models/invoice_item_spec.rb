# frozen_string_literal: true

require 'rails_helper'

describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end
end