require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validations" do
    subject { build(:category) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires unique slug" do
      create(:category, slug: "figures")
      subject.slug = "figures"
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "can have a parent category" do
      parent = create(:category)
      child = create(:category, parent_category: parent)

      expect(child.parent_category).to eq(parent)
      expect(parent.subcategories).to include(child)
    end
  end

  describe "slugs" do
    it "generates slug from name" do
      category = create(:category, name: "Action Figures")
      expect(category.slug).to eq("action-figures")
    end

    it "finds by slug using friendly_id" do
      category = create(:category, name: "Board Games")
      found = Category.friendly.find("board-games")
      expect(found).to eq(category)
    end
  end
end
