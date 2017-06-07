require 'open-uri'
require 'nokogiri'

# TODO: deal with redirects
# TODO: actually search for something!

def read_url_file
  File.readlines('./urls.txt').map(&:chomp)
end

def nokogiri_doc(path)
  begin
    Nokogiri::HTML(open(path))
  rescue OpenURI::HTTPError => e
    if e.message == "404 Not Found"
      return nil
    end
  end
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

      doc = nokogiri_doc(path)
      next if doc.nil?
      links = find_links(doc, path)
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
