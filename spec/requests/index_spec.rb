require 'spec_helper'

describe "Index" do
  it "returns the list of available APIs" do
    apis = {
      "/allergies.json" => "GET the list of available allergies",
      "/courses.json" => "GET the list of available courses",
      "/cuisines.json" => "GET the list of available cuisines",
      "/holidays.json" => "GET the list of available holidays",
      "/ingredients.json" => "GET the list of available ingredients"
    }
    visit '/'
    data = JSON.parse(page.body)
    expect(data['apis']).to eq(apis)
  end
end
