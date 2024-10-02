Given('I\'m on the page {string}') do |string|
  case string
  when "Home"
    visit root_path
  when "About"
    visit about_path
  when "Student"
    visit student_path
  else
    raise "Path not defined for #{string}"
  end
end

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end
