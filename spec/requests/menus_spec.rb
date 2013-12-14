require 'spec_helper'

describe "Menu request" do
	it "returns a 404 error if email is not given" do
		visit '/menu'
		expect(page.status_code).to eq(404)
	end
end