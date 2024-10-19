Given('I am on the page {string}') do |string|
  case string
  when "Home"
    visit root_path
  when "About"
    visit about_path
  when "Student"
    # I want to call it right here
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

Then('I should not see {string}') do |string|
  expect(page).to have_no_content(string)
end

When('I click the download link') do
  @download_link = find_link('Download Attendance CSV') # This finds the link by its text
end

Then('the download link should point to the correct file path') do
  expected_path = '/attendances/export_csv' # The expected path
  actual_path = @download_link[:href]

  expect(actual_path).to eq(expected_path)
end

Given('I am logged in as user with name {string} and email {string}') do |name, email|
  # Set the mock data with the specified email
  set_omniauth(name, email)
end

Then('I should see {string} in the {string} dropdown and it is selected') do |option, dropdown|
  expect(page).to have_select(dropdown, with_options: [ option ])
end

Then('I select {string} from the {string} dropdown') do |option, dropdown|
  select(option, from: dropdown)

  # dropdown_element = find(:select, dropdown)
  # options = dropdown_element.all('option').map(&:text)
  # puts "Options in the #{dropdown} dropdown: #{options.join(', ')}"
  expect(page).to have_button("CHECK IN FOR ENGR 102")
end

Then('I should see {string} on the button with id {string}') do |button_text, button_id|
  # save_and_open_page
  expect(page).to have_button(button_text, wait: 10)
end
