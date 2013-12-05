require 'spec_helper'

describe "Allergies" do

  it "returns a list of allergies" do
    visit '/allergies'
    data = JSON.parse(page.body)
    expect(data['allergies'].length).to be > 0
  end

  it "caches the allergies" do
    cache_file = File.join(File.dirname(__FILE__), '..', '..', 'public', 'allergies.json')
    File.unlink(cache_file) if File.exists?(cache_file)
    visit '/allergies'

    expect(File.exists?(cache_file)).to be true
  end
end
