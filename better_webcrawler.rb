require 'open-uri'
require 'nokogiri'

# TODO: deal with 404 errors
# TODO: deal with redirects
# TODO: actually search for something!

def read_url_file
  File.readlines('./urls.txt').map(&:chomp)
end

def nokogiri_doc(path)
  Nokogiri::HTML(open(path)) # 404 error!
end

def find_links(doc, path)
  links = doc.css('a').map { |link| link.attribute('href').to_s }
  links.map! { |link| link.start_with?("/") ? path + link : link }
  links.reject! { |link| link == "#" || link.nil? }
end

def crawl(max_depth = 3)
  depth = 0
  visited = {}
  url_list = read_url_file

  while depth < max_depth
    next_depth_urls = []

    url_list.each do |path|
      visited[path] = true
      puts "Searching #{path}"

      links = find_links(nokogiri_doc(path), path)
      next if links.nil?
      links.reject! { |link| visited[link] == true }
      next_depth_urls.push(*links)
    end

    url_list = next_depth_urls
    depth += 1
    puts "Links at depth #{depth}:"
  end
end

if __FILE__ == $PROGRAM_NAME
  crawl
end
