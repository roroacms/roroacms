require 'spec_helper'

RSpec.describe "Admin::Administrators", :type => :request do

  let(:admin) { FactoryGirl.create(:admin) }
  before { sign_in(admin) }

  describe "GET /admin/administrators" do

    before(:each) do
      visit "/admin/administrators"
    end

    it "should display administrators" do
      expect(page).to have_content "Users"
    end

    it "should have a button to allow user to create new administrator" do
      expect(page).to have_content "Add New User"
      click_link "Add New User"
      expect(current_path).to eq("/admin/administrators/new")
    end

  end

  describe "GET /admin/administrators/new" do

    let(:user) { FactoryGirl.build(:admin) }

    before(:each) do
      visit "/admin/administrators/new"
    end

    it "should create new user" do

      fill_in 'Email', :with => user.email
      fill_in 'Username', :with => user.username
      select 'admin', :from => 'admin_access_level'
      fill_in 'Password', :with => user.password
      fill_in 'admin_password_confirmation', :with => user.password
      click_button 'Save'

      expect(current_path).to eq("/admin/administrators")
      expect(page).to have_content "Admin was successfully created"

    end

    it "should not allow blank values" do

      click_button 'Save'
      expect(current_path).to eq("/admin/administrators")
      expect(page).to have_selector('.help-block.error')

    end

  end

  describe "PUT /admin/adminstrator/#id" do

    it "should edit an administrator" do

      visit "/admin/administrators"
      first(:linkhref, "/admin/administrators/#{admin.id}/edit").click

      expect(current_path).to eq("/admin/administrators/#{admin.id}/edit")
      expect(page).to have_content "Profile - #{admin.username}"
    end

  end

end
