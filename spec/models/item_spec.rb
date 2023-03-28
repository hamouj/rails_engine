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

  describe 'instance methods' do
    before(:each) do
      @customer_id = create(:customer).id
      @merchant_id = create(:merchant).id

      @item1 = create(:item, merchant_id: @merchant_id)
      @item2 = create(:item, merchant_id: @merchant_id)

      @invoice1 = create(:invoice, merchant_id: @merchant_id, customer_id: @customer_id)
      create(:invoice_item, item_id: @item1.id, invoice_id: @invoice1.id)

      @invoice2 = create(:invoice, merchant_id: @merchant_id, customer_id: @customer_id)
      create(:invoice_item, item_id: @item1.id, invoice_id: @invoice2.id)
      create(:invoice_item, item_id: @item2.id, invoice_id: @invoice2.id)
    end

    describe '#find_single_item_invoices' do
      it 'returns invoices where the item is the only item on the invoice' do
        expect(@item1.find_single_item_invoices).to eq([@invoice1])

        invoice3 = create(:invoice, merchant_id: @merchant_id, customer_id: @customer_id)
        create(:invoice_item, item_id: @item1.id, invoice_id: invoice3.id)

        expect(@item1.find_single_item_invoices).to eq([@invoice1, invoice3])
      end
    end
  end
end