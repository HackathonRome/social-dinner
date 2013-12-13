require 'spec_helper'

describe "Index" do
  it "returns the list of available APIs" do
    apis = {
      "/courses.json" => "GET the list of available courses",
      "/allergies.json" => "GET the list of available allergies",
      "/ingredients.json" => "GET the list of available ingredients"
    }
    visit '/'
    data = JSON.parse(page.body)
    expect(data['apis']).to eq(apis)
  end
end
