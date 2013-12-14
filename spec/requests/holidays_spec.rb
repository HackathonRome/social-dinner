require 'spec_helper'

describe "Holidays" do

  it "returns a list of holidays" do
    visit '/holidays'
    data = JSON.parse(page.body)
    expect(data['holidays'].length).to be > 0
  end

  it "caches the holidays" do
    cache_file = File.join(File.dirname(__FILE__), '..', '..', 'cache', 'holidays.json')
    File.unlink(cache_file) if File.exists?(cache_file)
    visit '/holidays'

    expect(File.exists?(cache_file)).to be true
  end
end
