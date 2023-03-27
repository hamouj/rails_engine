# frozen_string_literal: true

require 'rails_helper'

describe Customer, type: :model do
  describe 'relationships' do
    it { should have_many :invoices }
  end
end