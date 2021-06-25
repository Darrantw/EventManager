require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'american_date'


def optimum_hour
  contents = open_csv_file
  hours_array = Array.new
  hours_hash = Hash.new(0)

  contents.each do |row|
    date = row[:regdate]
    date = Time.parse(date)
    hour = date.hour
    hours_array.push(hour)
  end

  hours_array.reduce(hours_hash) do |hours_hash, h|
  hours_hash[h] += 1
  hours_hash
  end

  puts hours_array
  #for hours_hash.values.max
   # put 
     
end

def open_csv_file
  contents = CSV.open(
  'event_attendees.csv',
   headers: true,
   header_converters: :symbol
)
end

def signup_weekday(regdate)
  regdate = Date.parse(regdate)
  weekday = regdate.wday
  case weekday
  when 0
    weekday = "Sunday"
  when 1
    weekday = "Monday"
  when 2
    weekday = "Tuesday"
  when 3
    weekday = "Wednesday"
  when 4
    weekday = "Thursday"
  when 5
    weekday = "Friday"
  when 6
    weekday = "Saturday"
  end
end

def signup_hour(regdate) 
  regdate = Time.parse(regdate)
  hour = regdate.hour
  hour >= 12 ? hour = "#{hour % 12}PM" : hour = "#{hour}AM"
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end



def clean_phonenumber(homephone)
  homephone = homephone.to_s.scan(/\d/).join
  if (homephone.size > 10) && (homephone[0] == 1)
    homephone.to_s.rjust(10, '0')[1..10]
  else 
  homephone.to_s.rjust(10, '0')[0..9]
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

begin   
  civic_info.representative_info_by_address(
    address: zip,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody']
  ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end 
end

def save_thank_you_letter(id,form_letter)

  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end
puts "EventManager initialized!"

most_popular_day = Array.new 

sunday_counter = 0
saturday_counter = 0
monday_counter = 0
tuesday_counter = 0
wednesday_counter = 0
thursday_counter = 0
friday_counter = 0

most_popular_hour = Array.new 

twelve_am_counter = 0
one_am_counter = 0
two_am_counter = 0
three_am_counter = 0
four_am_counter = 0
fiveam_counter = 0
sixam_counter = 0
seven_am_counter = 0
eight_am_counter = 0
nine_am_counter = 0 
ten_am_counter = 0
nine_am_counter = 0
twelve_pm_counter = 0
one_pm_counter = 0
two_pm_counter = 0
three_pm_counter = 0
four_pm_counter = 0
five_pm_counter = 0
six_pm_counter = 0
seven_pm_counter = 0
eight_pm_counter = 0
nine_pm_counter = 0
ten_pm_counter = 0
eleven_pm_counter = 0

contents = CSV.open(
  'event_attendees.csv',
   headers: true,
   header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter



contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  homephone = clean_phonenumber(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)
  
  weekday = signup_weekday(row[:regdate]) 

  hour = signup_hour(row[:regdate]) 

  weekday = signup_weekday(row[:regdate]) 
  
  most_popular_day.push(weekday)

  most_popular_hour.push(hour)


  form_letter = erb_template.result(binding)

  
  
  save_thank_you_letter(id, form_letter)

end
  p most_popular_day.sort
  p most_popular_hour.sort
  

  for i in most_popular_day
    case i
    when "Sunday"
      sunday_counter += 1
    when "Monday"
      monday_counter += 1
    when "Tuesday"
      tuesday_counter += 1
    when "Wednesday"
      wednesday_counter += 1
    when "Thursday"
      thursday_counter += 1
    when "Friday"
      friday_counter += 1
    when "Saturday"
      saturday_counter += 1
    end
  end
  optimum_day = {"Sunday" => sunday_counter, "Monday" => monday_counter, "Tuesday" => tuesday_counter, "Wednesday" => wednesday_counter, "Thursday" => thursday_counter, "Friday" => friday_counter, "Saturday" => saturday_counter}
 optimum_day = optimum_day.sort_by {|key, value| -value}.to_h
 day1 = optimum_day.shift
 day2 = optimum_day.shift
 day3 = optimum_day.shift
puts "The most popular day for sign-ups is #{day1[0]} with #{day1[1]} sign-ups.
The second most popular day for sign-ups is #{day2[0]} with #{day2[1]} sign-ups.
And the third most popular day for sign-ups is #{day3[0]} with #{day3[1]} sign-ups.
"

optimum_hour = Hash.new(0)

most_popular_hour.each do |hour|
optimum_hour[hour] += 1
end
optimum_hour = optimum_hour.sort_by {|key, value| -value}.to_h
hour1 = optimum_hour.shift
hour2 = optimum_hour.shift
hour3 = optimum_hour.shift
puts "The most popular hour for sign-ups is #{hour1[0]} with #{hour1[1]} sign-ups.
The second most popular hour for sign-ups is #{hour2[0]} with #{hour2[1]} sign-ups.
And the third most popular hour for sign-ups is #{hour3[0]} with #{hour3[1]} sign-ups.
"

