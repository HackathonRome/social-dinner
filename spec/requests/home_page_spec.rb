require 'spec_helper'


describe "Home Page" do
  before { visit '/' }
  it "has the right content" do
    expect(page).to have_content("Hello World")
  end
end
