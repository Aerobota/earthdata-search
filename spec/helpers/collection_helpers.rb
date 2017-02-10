module Helpers
  module CollectionHelpers
    def use_collection(id, text)
      before :all do
        wait_for_xhr
        fill_in "keywords", with: id
        wait_for_xhr
        expect(find('#collection-results .panel-list-item:first-child, #collection-results .ccol:first-child')).to have_content(text)
      end

      after :all do
        reset_search
        wait_for_xhr
      end
    end

    def for_collapsed_collection(id, text)
      wait_for_xhr
      fill_in "keywords", with: id
      wait_for_xhr
      expect(first_collapsed_collection).to have_content(text)
      yield
      reset_search
      wait_for_xhr
    end

    def view_granule_results(col_name='15 Minute Stream Flow Data: USGS (FIFE)', from='collection-results')
      find("h3", :text => col_name, :exact => true).find(:xpath, '../..').find(".button", :text => "View Granules").click
      wait_for_xhr
      expect(page).to have_selector('#granules-scroll', visible: true)
    rescue => e
      Capybara::Screenshot.screenshot_and_save_page
      puts "Visible overlay: #{OverlayUtil::current_overlay_id(page)}"
      raise e
    end

    def view_minimized_granule_results(col_name='15 Minute Stream Flow Data: USGS (FIFE)')
      page.execute_script ("$(\"#" + col_name + "-map\").click()")
    end

    def leave_granule_results(to='collection-results')
      wait_for_xhr
      expect(page).to have_selector('#granules-scroll', visible: true)
      page.execute_script("$('#granule-list a.master-overlay-back').click()")
      wait_for_xhr
      wait_for_visualization_unload
      expect(page).to have_visible_overlay(to)
    rescue => e
      Capybara::Screenshot.screenshot_and_save_page
      puts "Visible overlay: #{OverlayUtil::current_overlay_id(page)}"
      raise e
    end

    def add_to_project(col_name)
      wait_for_xhr
      page.execute_script("$('#collection-results-list .panel-list-item:contains(\"#{col_name}\") a.add-to-project').click()")
      wait_for_xhr
    end

    def hook_granule_results(col_name='15 Minute Stream Flow Data: USGS (FIFE)', scope=:all, from='collection-results')
      before(scope) { view_granule_results(col_name, from) }
      after(scope) { leave_granule_results }
    end

    def hook_granule_results_back(col_name='15 Minute Stream Flow Data: USGS (FIFE)')
      before :all do
        view_granule_results(col_name)
        leave_granule_results
      end
    end

    private

    def wait_for_visualization_unload
      expect(page).to have_no_selector('.leaflet-tile-pane .leaflet-layer:nth-child(2) canvas')
    end

    def wait_for_visualization_load
      #synchronize(120) do
      #  expect(page.evaluate_script('edsc.page.map.map.loadingLayers')).to eql(0)
      #end
    end
  end
end
