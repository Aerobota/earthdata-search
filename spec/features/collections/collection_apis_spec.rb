require 'spec_helper'

describe 'Collection API Endpoints', reset: false do
  context 'when viewing the collection details for a collection with granules' do
    before :all do
      load_page '/search', env: :sit
      wait_for_xhr
      click_link "Temporal"
      fill_in "Start", with: "1985-12-01 00:00:00\t\t"
      js_click_apply ".temporal-dropdown"
      wait_for_xhr

      fill_in 'keywords', with: 'C1000000257-DEV07'
      wait_for_xhr
      first_collection_result.click
      wait_for_xhr
    end

    it 'provides a link to the CMR API for the collections granules' do
      expect(collection_details).to have_css('a[href="https://cmr.sit.earthdata.nasa.gov/search/granules.json?temporal=1985-12-01T00%3A00%3A00.000Z%2C&echo_collection_id=C1000000257-DEV07&sort_key%5B%5D=-start_date&page_size=20"]')
    end
  end

  context 'when viewing the collection details for a collection with GIBS' do
    before :all do
      load_page :search, env: :sit
      fill_in 'keywords', with: 'C24936-LAADS'
      wait_for_xhr
      first_collection_result.click
      wait_for_xhr
    end

    it 'provides the path to the GIBS endpoint' do
      expect(collection_details).to have_css('a[href="http://map1.vis.earthdata.nasa.gov/wmts-geo/MODIS_Terra_Aerosol/default/{Time}/EPSG4326_2km/{ZoomLevel}/{TileRow}/{TileCol}.png"]')
    end
  end

  context 'when viewing the collection details for a collection with OPeNDAP' do
    before :all do
      load_page :search
      fill_in 'keywords', with: 'C2921042-PODAAC'
      wait_for_xhr
      first_collection_result.click
      wait_for_xhr
    end

    it 'provides a link to the OPeNDAP endpoint' do
      expect(collection_details).to have_css('a[href="http://podaac-opendap.jpl.nasa.gov/opendap/allData/coastal_alt/preview/L4/OSU_COAS/weekly/"]')
    end
  end

  context 'when viewing the collection details for a collection with MODAPS WCS' do
    before :all do
      load_page :search
      fill_in 'keywords', with: 'C1219032686-LANCEMODIS'
      wait_for_xhr
      first_collection_result.click
      wait_for_xhr
    end

    it 'provides the path to the MODAPS WCS endpoint' do
      expect(collection_details).to have_css('a[href="http://modwebsrv.modaps.eosdis.nasa.gov/wcs/5/MYD04_L2/getCapabilities?service=WCS&version=1.0.0&request=GetCapabilities"]')
    end
  end

  context 'when viewing the collection details for a collection without granules, GIBS, or OPeNDAP' do
    before :all do
      load_page :search
      fill_in 'keywords', with: 'C179001887-SEDAC'
      wait_for_xhr
      first_collection_result.click
      wait_for_xhr
    end

    it 'does not provide a link to the CMR API for granules' do
      expect(collection_details).to have_no_content 'CMR'
    end

    it 'does not provide a link to the GIBS endpoint' do
      expect(collection_details).to have_no_content 'GIBS'
    end

    it 'does not provide a link to the OPeNDAP endpoint' do
      expect(collection_details).to have_no_content 'OPeNDAP'
    end

    it 'does not provide a link to the MODAPS WCS endpoint' do
      expect(collection_details).to have_no_content 'MODAPS WCS'
    end
  end
end
