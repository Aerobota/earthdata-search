require "spec_helper"

describe "Data download page", reset: false do
  downloadable_dataset_id = 'C179003030-ORNL_DAAC'
  downloadable_dataset_title = '15 Minute Stream Flow Data: USGS (FIFE)'

  non_downloadable_dataset_id = 'C179001887-SEDAC'
  non_downloadable_dataset_title = '2000 Pilot Environmental Sustainability Index (ESI)'

  before(:all) do
    visit "/search"

    click_link 'Sign In'
    fill_in 'Username', with: 'edsc'
    fill_in 'Password', with: 'EDSCtest!1'
    click_button 'Sign In'
    wait_for_xhr
  end

  after(:all) do
    reset_user
    visit "/search"
  end

  context "when datasets have been selected for direct download" do
    before :all do
      add_dataset_to_project(downloadable_dataset_id, downloadable_dataset_title)
      add_dataset_to_project(non_downloadable_dataset_id, non_downloadable_dataset_title)

      dataset_results.click_link "View Project"
      click_link "Retrieve project data"

      # Download the first
      choose 'Download'
      click_on 'Continue'
      # No actions available on the second, continue
      click_on 'Continue'
      # Confirm address
      click_on 'Submit'
    end

    after :all do
      visit "/search"
    end

    it "displays information on using direct download" do
      expect(page).to have_content('The following datasets are available for immediate download')
    end

    it "displays a link to access a page containing direct download urls for datasets chosen for direct download" do
      expect(page).to have_link('View Download Links')
    end

    it "displays a link to access a page containing direct download urls for datasets chosen for direct download" do
      expect(page).to have_link('Download Access Script')
    end

    it "displays no links for direct downloads for datasets that were not chosen for direct download" do
      expect(page).to have_no_content(non_downloadable_dataset_title)
    end

    context "upon clicking on a direct download link" do
      before :all do
        click_link "View Download Link"
      end

      it "displays a page containing direct download hyperlinks for the dataset's granules in a new window" do
        within_window('Earthdata Search - Downloads') do
          expect(page).to have_link("http://daac.ornl.gov/data/fife/data/hydrolgy/strm_15m/y1984/43601715.s15")
        end
      end
    end

    context "upon clicking on a direct download link" do
      before :all do
        click_link "Download Access Script"
      end

      it "downloads a shell script which performs the user's query" do
        within_window(page.driver.browser.get_window_handles.last) do
          expect(page).to have_content('#!/bin/sh')
          expect(page).to have_content('echo_collection_id%5B%5D=C179003030-ORNL_DAAC')
        end
      end
    end
  end

  context "when no datasets have been selected for direct download" do
    before :all do
      add_dataset_to_project(non_downloadable_dataset_id, non_downloadable_dataset_title)

      dataset_results.click_link "View Project"
      click_link "Retrieve project data"

      # No options available, continue to set address
      click_on 'Continue'
      # Confirm address
      click_on 'Submit'
    end

    after :all do
      visit '/search'
    end

    it "displays no information on direct downloads" do
      expect(page).to have_no_content('The following datasets are available for immediate download')
    end
  end
end