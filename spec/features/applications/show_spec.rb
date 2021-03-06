require 'rails_helper'

describe 'As a visitor' do
  describe 'When I visit an application show page' do
    before (:each) do
      @user = create(:user)
      @shelter = create(:shelter)
      @pet = create(:pet, name: 'Pugalicious', shelter: @shelter)

      @app = create(:application, user: @user, status: 'In Progress')
      @pet_application = create(
        :pet_application,
        pet: @pet,
        application: @app
      )
    end

    it 'I see the application information' do
      visit "/applications/#{@app.id}"

      expect(page).to have_content(@app.user.name)
      expect(page).to have_content(@app.user.street_address)
      expect(page).to have_content(@app.user.city)
      expect(page).to have_content(@app.user.zip)
      expect(page).to have_content(@app.description)
      expect(page).to have_link(@app.pets.first.name)
      expect(page).to have_content(@app.status)
    end

    it 'I see a section to add a pet to this application' do
      pet2 = create(:pet)

      visit "/applications/#{@app.id}"

      fill_in :pet_name, with: pet2.name

      first(:button, "Submit").click

      expect(current_path).to eq("/applications/#{@app.id}")

      within('.pet') do
        expect(page).to have_content(pet2.name)
      end
    end

    it 'I can add a pet to the application' do
      pet2 = create(:pet)

      visit "/applications/#{@app.id}"

      fill_in :pet_name, with: pet2.name

      first(:button, "Submit").click

      expect(current_path).to eq("/applications/#{@app.id}")

      first(:button, 'Adopt this Pet').click

      expect(current_path).to eq("/applications/#{@app.id}")

      expect(page).to have_link(pet2.name)
    end

    it 'I can not add a pet to the application twice' do
      pet2 = create(:pet)

      visit "/applications/#{@app.id}"

      fill_in :pet_name, with: pet2.name

      first(:button, "Submit").click

      expect(current_path).to eq("/applications/#{@app.id}")

      first(:button, 'Adopt this Pet').click

      expect(current_path).to eq("/applications/#{@app.id}")

      expect(page).to have_link(pet2.name)

      fill_in :pet_name, with: pet2.name

      first(:button, "Submit").click

      within("#pet-#{pet2.id}") do
        expect(page).to have_content('Already Added')
        expect(page).to_not have_button('Adopt this Pet')
      end
    end

    it 'I can submit an application after adding required info' do
      visit "/pets"
      click_on "Start an Application"

      fill_in :user_name, with: @user.name
      first(:button, "Submit").click

      fill_in :pet_name, with: @pet.name
      first(:button, "Submit").click

      first(:button, 'Adopt this Pet').click

      expect(page).to have_content("Application Submission")

      fill_in :description, with: 'I have a great house and love iguanas.'
      within(".app-submit") do
        click_button 'Submit'
      end

      app = @user.applications.last
      expect(current_path).to eq("/applications/#{app.id}")
      expect(page).to have_content("Status: Pending")
      expect(page).to have_content("Description: I have a great house and love iguanas.")
      expect(page).to have_content(app.pets.first.name)
      expect(page).to_not have_content('Add a Pet to this Application')
    end

    it "I can't see the ability to submit the app unless it has pets" do
      app = create(:application)

      visit "/applications/#{app.id}"

      expect(page).to_not have_content("Application Submission")
    end

    it "I cannot submit an application without a description" do
      app = create(:application, description: "", status: "In Progress")
      create(:pet_application, application: app)

      visit "/applications/#{app.id}"

      within(".app-submit") do
        click_button 'Submit'
      end

      expect(page).to have_content("Required field: Description")
      expect(page).to have_content("Status: In Progress")
    end

    it "I can search for pets that kinda match the name" do
      bun = create(:pet, name: "Bun")
      bunbun = create(:pet, name: "BunBun")

      visit "/applications/#{@app.id}"

      fill_in :pet_name, with: 'bUn'
      first(:button, "Submit").click

      expect(page).to have_content(bun.name)
      expect(page).to have_content(bunbun.name)
    end

    it "I get a notice when there are no matching results" do
      bun = create(:pet, name: "Bun")
      bunbun = create(:pet, name: "BunBun")

      visit "/applications/#{@app.id}"

      fill_in :pet_name, with: 'JimJoeBob'
      first(:button, "Submit").click

      expect(page).to_not have_content(bun.name)
      expect(page).to_not have_content(bunbun.name)
      expect(page).to have_content("Could not find a pet by that name")
    end
  end
end
