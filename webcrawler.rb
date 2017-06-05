require 'open-uri'

def crawl(url_list, max_phone_nums = 100)
  phone_numbers = []
  count = 0
  visted = {}

  until url_list.empty? || count >= max_phone_nums
    path = url_list.shift
    str = open_url(path)
    puts "Searching #{path}"

    numbers = find_numbers(str)
    phone_numbers.push(*numbers)
    count += numbers.length

    links = find_links(str)
    links.each do |link|
      unless visted[link]
        url_list.push(link)
        visted[link] = true
      end
    end
  end
  puts "#{count} phone numbers found."
  phone_numbers.each { |num| p num }
end

def open_url(path)
  open(path) do |data|
    return data.read
  end
end

def find_numbers(str)
  nums = "1234567890"
  possible_numbers = []
  i = 0
  while i < str.length - 11
    if nums.include?(str[i]) && nums.include?(str[i + 1]) && nums.include?(str[i + 2])
      possible_numbers << str[i..(i + 11)]
    end
    i += 1
  end
  possible_numbers.grep(/\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\z/)
end

def find_links(str)
  URI.extract(str).select do |path|
    path.start_with?("http://") || path.start_with?("https://")
  end
end

# str = open_url("https://www.google.com/")
# p find_links(str)
# p find_numbers("603 277 0187 sk hi my name is 603-487-4859 claire (603) 488-6845")

crawl(["http://www.google.com"])
