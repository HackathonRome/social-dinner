require 'spec_helper'

describe "Courses" do

  it "returns a list of courses" do
    visit '/courses'
    data = JSON.parse(page.body)
    expect(data['courses'].length).to be > 0
  end

  it "caches the courses" do
    cache_file = File.join(File.dirname(__FILE__), '..', '..', 'public', 'courses.json')
    File.unlink(cache_file) if File.exists?(cache_file)
    visit '/courses'

    expect(File.exists?(cache_file)).to be true
  end
end
