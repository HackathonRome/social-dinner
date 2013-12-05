require 'spec_helper'

describe "Courses" do
  before { visit '/courses' }

  it "returns a list of courses" do
    data = JSON.parse(page.body)
    expect(data['courses'].length).to be > 0
  end
end
