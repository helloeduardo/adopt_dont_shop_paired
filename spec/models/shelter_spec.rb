require 'rails_helper'

describe Shelter, type: :model do
  describe 'relationships' do
    it { should have_many :pets }
    it { should have_many :reviews }
  end

  describe 'class methods' do
    it '.sorted_by' do

    end
  end

  describe 'instance methods' do
    it '.pet_count' do
      shelter = create(:shelter)
      create_list(:pet, 5, shelter: shelter)

      expect(shelter.pet_count).to eq(5)
    end

    it '.average_rating' do
      shelter = create(:shelter)
      create(:review, rating: 5, shelter: shelter)
      create(:review, rating: 1, shelter: shelter)
      create(:review, rating: 1, shelter: shelter)

      expect(shelter.average_rating.round(2)).to eq(2.33)
    end

    it '.application_count' do
      shelter = create(:shelter)
      pet1 = create(:pet, shelter: shelter)
      pet2 = create(:pet, shelter: shelter)

      create(:pet_application, pet: pet1)
      create(:pet_application, pet: pet1)
      create(:pet_application, pet: pet2)
      create(:pet_application, pet: pet2)
      create(:pet_application, pet: pet2)

      shelter2 = create(:shelter)
      pet3 = create(:pet, shelter: shelter2)
      create(:pet_application, pet: pet3)
      create(:pet_application, pet: pet3)

      expect(shelter.application_count).to eq(5)
      expect(shelter2.application_count).to eq(2)
    end

    it '.has_approvals?' do
      shelter = create(:shelter)

      expect(shelter.has_approvals?).to eq(false)

      shelter = create(:shelter)
      pet = create(:pet, shelter: shelter)
      application = create(:application, status: 'Approved')
      create(:pet_application, pet: pet, application: application)

      expect(shelter.has_approvals?).to eq(true)
    end
  end
end
