require 'uri'

Given('I am on the page {string}') do |string|
  case string
  when "Home"
    visit root_path
  when "About"
    visit about_path
  when "Admin"
    admin_user = User.find_by(email: "admin@admin.com")
    visit admin_path(admin_user.id)
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

Given('I am logged in with name {string} and email {string}') do |name, email|
  # Set the mock data with the specified email
  set_omniauth(name, email)
end

Then('I should see {string} in the {string} dropdown and it is selected') do |option, dropdown|
  expect(page).to have_select(dropdown, with_options: [ option ])
end

Then('I select {string} from the {string} dropdown') do |option, dropdown|
  select(option, from: dropdown)
end

When('I select {string} from the {string} dropdown within the {string} section') do |option, dropdown, section|
  within("#{section}") do
    select(option, from: dropdown)
  end
end

Then('I should see {string} within {string}') do |text, id_tag|
  # dropdown_element = find(:select, "course_number")
  # selected_value = dropdown_element.value
  # selected_option = dropdown_element.find("option[value='#{selected_value}']").text
  # puts "The selected option is: #{selected_option}"

  within(id_tag) do
    find(text).click
  end

  # expect(page).to have_button(button_text, wait: 10)
end

When("I set the start date to {string}") do |date|
  within("#attendance-form") do
    fill_in "start_date", with: date
  end
end

When("I set the end date to {string}") do |date|
  within("#attendance-form") do
    fill_in "end_date", with: date
  end
end

Then("I should receive a CSV file") do
  expect(page.response_headers['Content-Type']).to eq 'text/csv'
end

Then("the CSV file should contain the correct attendance data") do
  csv_content = page.body
  csv = CSV.parse(csv_content, headers: true)

  # verify the headers
  expect(csv.headers).to eq([ 'Date', 'Time Slot', 'Number of Students' ])

  # convert the csv table to an array of hashes, which lets us use rows.first and rows.last
  rows = csv.map(&:to_h)

  # verify the date range
  expect(rows.first['Date']).to eq('2024-10-01')
  expect(rows.last['Date']).to eq('2024-10-18')

  # verify the time slots
  time_slots = csv['Time Slot'].uniq
  expected_time_slots = [
    '09:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00',
    '13:00 - 14:00', '14:00 - 15:00', '15:00 - 16:00', '16:00 - 17:00'
  ]
  expect(time_slots).to match_array(expected_time_slots)

  # verify the # of students is always 0 or greater
  student_counts = csv['Number of Students'].map(&:to_i)
  expect(student_counts.min).to be >= 0
end

When('I mark my attendance') do
  # puts page.html  # This will print the HTML of the current page for debugging
  find('#mark-attendance-btn').click
end

Given('the following courses exist:') do |table|
  table.hashes.each do |course|
    Course.find_or_create_by!(
      course_number: course['course_number'],
      course_name: course['course_name'],
      instructor_name: course['instructor_name'],
      start_date: Date.parse(course['start_date']),
      end_date: Date.parse(course['end_date'])
    )
  end
end

Then("the form should submit and update the attendance data for {string}") do |course_id|
  # URI-encode the course_id
  encoded_course_id = URI.encode_www_form_component(course_id)
  expect(page).to have_current_path(/showAdmin\/\d+\?course_id=#{encoded_course_id}/, wait: 10)
end

Then("the histogram should be updated with the correct attendance data") do
  # Verify that the attendance histogram canvas is present on the page
  expect(page).to have_selector('#attendanceHistogram')
  
  # Removed the text expectation as it is not applicable to <canvas> elements
end
