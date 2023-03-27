# frozen_string_literal: true

require 'rails_helper'

describe Item, type: :model do
  describe 'relationships' do
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should belong_to :merchant }
  end

  describe 'class_methods' do
    before(:each) do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)

      @item1 = create(:item, merchant_id: @merchant1.id)
      @item2 = create(:item, merchant_id: @merchant1.id)
      @item3 = create(:item, merchant_id: @merchant2.id)
    end

    describe '::for_merchant()' do
      it 'returns a list of items for a given merchant' do
        expect(Item.for_merchant(@merchant1.id)).to eq([@item1, @item2])

        item4 = create(:item, merchant_id: @merchant1.id)

        expect(Item.for_merchant(@merchant1.id)).to eq([@item1, @item2, item4])
      end
    end
  end
end