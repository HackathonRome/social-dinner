require 'spec_helper'

describe "Ingredients" do

  it "returns a list of ingredients" do
    visit '/ingredients'
    data = JSON.parse(page.body)
    expect(data['ingredients'].length).to be > 0
  end

  it "caches the ingredients" do
    cache_file = File.join(File.dirname(__FILE__), '..', '..', 'public', 'ingredients.json')
    File.unlink(cache_file) if File.exists?(cache_file)
    visit '/ingredients'

    expect(File.exists?(cache_file)).to be true
  end
end
