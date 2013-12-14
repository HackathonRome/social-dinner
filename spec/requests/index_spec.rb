require 'spec_helper'

describe "Index" do
  it "returns the list of available APIs" do
    apis = {
      "/allergies" => "GET the list of available allergies",
      "/courses" => "GET the list of available courses",
      "/cuisines" => "GET the list of available cuisines",
      "/holidays" => "GET the list of available holidays",
      "/ingredients" => "GET the list of available ingredients"
    }
    visit '/'
    data = JSON.parse(page.body)
    expect(data['apis']).to eq(apis)
  end
end
