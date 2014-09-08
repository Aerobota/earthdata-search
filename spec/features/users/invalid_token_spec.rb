require 'spec_helper'

describe 'Invalid user token', reset: false do
  before :all do
    Capybara.reset_session!
  end

  context 'Making an ECHO request with an invalid token' do
    before :all do
      be_logged_in_as 'edsc'
      page.set_rack_session(access_token: 'invalid')

      load_page :root

      fill_in 'keywords', with: 'C179001889-SEDAC'
      click_link 'Browse All Data'
    end

    it 'logs out the user' do
      expect(page).to have_content 'URS Sign In'
    end

    it 'displays search results' do
      expect(page).to have_content '2005 Environmental Sustainability Index (ESI)'
    end
  end

end
