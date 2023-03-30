# frozen_string_literal: true

require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many :invoices }
    it { should have_many :items }
  end

  describe "class methods" do
    before(:each) do
      @jasmine = create(:merchant, name: "Jasmine")
      @rostam = create(:merchant, name: "Rostam")
    end

    describe "::find_by_name()" do
      it "returns a merchant based on a complete name match" do
        expect(Merchant.find_by_name("Jasmine")).to eq(@jasmine)
        expect(Merchant.find_by_name("Rostam")).to eq(@rostam)
      end

      it "returns a merchant based on a partial name match" do
        expect(Merchant.find_by_name("min")).to eq(@jasmine)
        expect(Merchant.find_by_name("tam")).to eq(@rostam)
      end

      it "returns a merchant based on a parital name match (case insensitive)" do
        expect(Merchant.find_by_name('jas')).to eq(@jasmine)
        expect(Merchant.find_by_name('ro')).to eq(@rostam)
      end

      it "returns the first alphabetical name match when there are two matches" do
        kastam = create(:merchant, name: 'kastam')

        expect(Merchant.find_by_name('as')).to eq(@jasmine)
        expect(Merchant.find_by_name('tam')).to eq(kastam)
      end

      it "returns nil when there are no matches" do
        expect(Merchant.find_by_name('x')).to eq(nil)
      end
    end
  end
end