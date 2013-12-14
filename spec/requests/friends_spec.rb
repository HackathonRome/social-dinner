require 'spec_helper'

describe "Friends" do
	it "return a list of friends" do
		visit '/friends/giuseppe.modarelli@gmail.com'
		expect(page.status_code).to eq(200)
		data = JSON.parse(page.body)
		expect(data['friends'].length).to eq(7)
	end
end