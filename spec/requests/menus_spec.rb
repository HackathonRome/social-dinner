require 'spec_helper'

describe "Menu request" do
	it "returns a 404 error if email is not given" do
		visit '/menu'
		expect(page.status_code).to eq(404)
	end

	it "returns an error if the list of friends is not given" do
		visit '/menu/giuseppe.modarelli@gmail.com'
		expect(page.body).to match /You must specify a list of friends/
	end
end