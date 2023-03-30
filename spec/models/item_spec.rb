# frozen_string_literal: true

require 'rails_helper'

describe Item, type: :model do
  describe 'relationships' do
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should belong_to :merchant }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of :unit_price }
  end

  describe 'class_methods' do
    before(:each) do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)

      @item1 = create(:item, merchant_id: @merchant1.id, name: "Jasmine", unit_price: 31.24)
      @item2 = create(:item, merchant_id: @merchant1.id, name: "Rostam", unit_price: 25.34)
      @item3 = create(:item, merchant_id: @merchant2.id, name: "Kastam", unit_price: 23)
    end

    describe '::for_merchant()' do
      it 'returns a list of items for a given merchant' do
        expect(Item.for_merchant(@merchant1.id)).to eq([@item1, @item2])

        item4 = create(:item, merchant_id: @merchant1.id)

        expect(Item.for_merchant(@merchant1.id)).to eq([@item1, @item2, item4])
      end
    end

    describe "::find_by_name()" do
      it "returns a Item based on a complete name match" do
        expect(Item.find_by_name("Jasmine")).to eq([@item1])
        expect(Item.find_by_name("Rostam")).to eq([@item2])
      end

      it "returns a Item based on a partial name match" do
        expect(Item.find_by_name("min")).to eq([@item1])
        expect(Item.find_by_name("os")).to eq([@item2])
      end

      it "returns a Item based on a parital name match (case insensitive)" do
        expect(Item.find_by_name('jas')).to eq([@item1])
        expect(Item.find_by_name('ro')).to eq([@item2])
      end

      it "returns all partial and complete name matches in alphabetical order" do
        expect(Item.find_by_name('as')).to eq([@item1, @item3])
        expect(Item.find_by_name('am')).to eq([@item3, @item2])
      end

      it "returns an empty array when there are no matches" do
        expect(Item.find_by_name('x')).to eq([])
      end
    end

    describe "::find_by_min_price()" do
      it "returns items that are greater than or equal to the given price" do
        expect(Item.find_by_min_price(24)).to eq([@item2, @item1])
        expect(Item.find_by_min_price(20.2)).to eq([@item3, @item2, @item1])
      end

      it "returns an empty array when there are no matches" do
        expect(Item.find_by_min_price(60.03)).to eq([])
      end
    end

    describe "::find_by_max_price()" do
      it "returns items that are less than or equal to the given price" do
        expect(Item.find_by_max_price(24)).to eq([@item3])
        expect(Item.find_by_max_price(25.34)).to eq([@item3, @item2])
      end

      it "returns an empty array when there are no matches" do
        expect(Item.find_by_max_price(0.03)).to eq([])
      end
    end

    describe "::find_by_min_max_price()" do
      it "returns items that are less than or equal to the given price" do
        expect(Item.find_by_min_max_price(24, 40)).to eq([@item2, @item1])
        expect(Item.find_by_min_max_price(20.1, 70)).to eq([@item3, @item2, @item1])
      end

      it "returns an empty array when there are no matches" do
        expect(Item.find_by_min_max_price(0.03, 1)).to eq([])
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