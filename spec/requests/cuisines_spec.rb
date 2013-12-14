require 'spec_helper'

describe "Cuisines" do

  it "returns a list of cuisines" do
    visit '/cuisines'
    data = JSON.parse(page.body)
    expect(data['cuisines'].length).to be > 0
  end

  it "caches the cuisines" do
    cache_file = File.join(File.dirname(__FILE__), '..', '..', 'cache', 'cuisines.json')
    File.unlink(cache_file) if File.exists?(cache_file)
    visit '/cuisines'

    expect(File.exists?(cache_file)).to be true
  end
end
