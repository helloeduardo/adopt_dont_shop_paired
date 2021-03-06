require 'rails_helper'

describe Pet, type: :model do
  describe 'relationships' do
    it { should belong_to :shelter }
    it { should have_many :pet_applications }
    it { should have_many(:applications).through(:pet_applications) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :image }
  end

  describe 'class methods' do
    it '.display_by' do
      pet1 = create(:pet, adoptable: true)
      pet2 = create(:pet, adoptable: false)
      pet3 = create(:pet, adoptable: true)
      pet4 = create(:pet, adoptable: false)

      expect(Pet.display_by("true")).to eq([pet1, pet3])
      expect(Pet.display_by("false")).to eq([pet2, pet4])
      expect(Pet.display_by(nil)).to eq([pet1, pet3, pet2, pet4])
    end

    it '.adopted_pets' do
      adopted_pet1 = create(:pet, adoptable: false)
      adopted_pet2 = create(:pet, adoptable: false)
      app_approved = create(:application, status: 'Approved')
      app_unapproved = create(:application, status: 'Pending')
      create(:pet_application, pet: adopted_pet1, application: app_approved)
      create(:pet_application, pet: adopted_pet2, application: app_unapproved)

      expect(Pet.adopted_pets).to eq([adopted_pet1])
      expect(Pet.adopted_pets).to_not eq([adopted_pet1, adopted_pet2])
    end

    it '::count_of_pets' do
      create_list(:pet, 5)

      expect(Pet.count_of_pets).to eq(5)
    end

    it '::with_names_like(name)' do
      pet1 = create(:pet, name: "Perry The Parakeet")
      pet2 = create(:pet, name: "Perocles")
      pet3 = create(:pet, name: "Kerry")

      expect(Pet.with_names_like("per")).to eq([pet1, pet2])
      expect(Pet.with_names_like("ker")).to eq([pet3])
    end
  end


  describe 'instance methods' do
    it '.status' do
      shelter = Shelter.create!()
      pet_1 = create(:pet, shelter: shelter)
      pet_2 = create(:pet, shelter: shelter, adoptable: false)

      expect(pet_1.status).to eq('Adoptable')
      expect(pet_2.status).to eq('Pending Adoption')
    end

    it ".pet_application" do
      pet = create(:pet)
      application = create(:application)
      pet_application1 = create(:pet_application, application: application, pet: pet)
      pet_application2 = create(:pet_application, pet: pet)
      expect(pet.pet_application(application.id)).to eq(pet_application1)
      expect(pet.pet_application(application.id)).to_not eq(pet_application2)
    end

    it '.has_approvals?' do
      pet = create(:pet)

      expect(pet.has_approvals?).to eq(false)

      user = create(:user)
      pet.applications.create!(user_id: user.id, status: "Approved")

      expect(pet.has_approvals?).to eq(true)
    end
  end
end
