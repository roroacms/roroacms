require 'spec_helper'

RSpec.describe "Admin::Themes", :type => :request do

  let!(:admin) { FactoryGirl.create(:admin) }
  before { sign_in(admin) }

  describe "GET /admin/themes" do

    before(:each) do
      visit "/admin/themes"
    end

    it "should display the avalible themes" do

      expect(page).to have_content('Themes')
      expect(page).to have_content('roroa 1')

    end

    it "should allow you to update the current theme" do

      find('#theme_roroa1').set(true)
      find('button[type=submit]').click

      expect(current_path).to eq("/admin/themes")
      expect(page).to have_content('Success!')

    end

  end

end
