Given('I\'m on the page {string}') do |string|
  case string
  when "Home"
    visit root_path
  when "About"
    visit about_path
  else
    raise "Path not defined for #{string}"
  end
end

When("I click {string}") do |button|
  click_button button
end

When("I click link {string}") do |link|
  click_link link
end

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end

When('I click the download link') do
  @download_link = find_link('Download Attendance CSV') # This finds the link by its text
end

Then('the download link should point to the correct file path') do
  expected_path = '/attendances/export_csv' # The expected path
  actual_path = @download_link[:href]

  expect(actual_path).to eq(expected_path)
end
  
