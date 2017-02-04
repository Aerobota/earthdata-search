require 'spec_helper'

describe 'Collections overlay', :reset => false do
  before(:all) do
    Capybara.reset_sessions!
    load_page :search
  end

  after(:each) do
    reset_overlay
    reset_project
  end

  it "shows collection details when clicking on a collection" do
    expect(page).to have_visible_collection_results
    expect(page).to_not have_visible_collection_details
    first_collection_result.click
    expect(page).to_not have_visible_collection_results
    expect(page).to have_visible_collection_details
  end

  context "after returning to the collection list from the project view" do
    before(:all) do
      first_collection_result.click_link "Add collection to the current project"
      second_collection_result.click_link "Add collection to the current project"
      find_by_id("view-project").click
      wait_for_xhr
      Capybara::Screenshot.screenshot_and_save_page
      click_on 'Back to Collection Search'
    end

    it "shows facet list" do
      expect(page).to have_selector('#master-overlay-parent', visible: true)
    end

    it "shows collection details when clicking on a collection" do
      first_collection_result.click
      expect(page).to have_visible_collection_details
    end
  end

  context "clicking to close facet list and adding collections to a project" do
    before :all do
      load_page :search, facets: true
      manual_close_facet_list

      first_collection_result.click_link "Add collection to the current project"
      second_collection_result.click_link "Add collection to the current project"
      find_by_id("view-project").click
    end

    after :all do
      reset_overlay
      reset_project
    end

    context "returning to the collections list from the project view" do
      before :all do
        wait_for_xhr
        click_on 'Back to Collection Search'
      end
      it "doesn't show facet list" do
        expect(page).to have_selector('#master-overlay-parent', visible: false)
      end
    end
  end
end
