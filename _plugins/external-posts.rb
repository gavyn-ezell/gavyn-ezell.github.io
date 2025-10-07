require 'feedjira'
require 'httparty'
require 'jekyll'
require 'nokogiri'
require 'time'

module ExternalPosts
  class ExternalPostsGenerator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      if site.config['external_sources'] != nil
        site.config['external_sources'].each do |src|
          puts "Fetching external posts from #{src['name']}:"
          if src['rss_url']
            fetch_from_rss(site, src)
          elsif src['posts']
            fetch_from_urls(site, src)
          end
        end
      end
    end

    def fetch_from_rss(site, src)
      # Add proper headers to avoid being blocked
      headers = {
        'User-Agent' => 'Mozilla/5.0 (compatible; Jekyll External Posts Plugin)',
        'Accept' => 'application/rss+xml, application/xml, text/xml'
      }
      
      response = HTTParty.get(src['rss_url'], headers: headers, timeout: 10)
      
      # Check if the response was successful
      unless response.success?
        puts "   ERROR: Failed to fetch RSS feed (HTTP #{response.code})"
        return
      end
      
      xml = response.body
      return if xml.nil? || xml.strip.empty?
      
      # Add error handling for Feedjira parsing
      begin
        feed = Feedjira.parse(xml)
        
        # Check if feed parsing was successful
        if feed.nil?
          puts "   ERROR: Failed to parse RSS feed - feed is nil"
          return
        end
        
        # Check if feed is actually an error object
        if feed.is_a?(Numeric) || !feed.respond_to?(:entries)
          puts "   ERROR: RSS feed parsing failed - invalid feed format"
          return
        end
        
        process_entries(site, src, feed.entries)
      rescue Feedjira::NoParserAvailable => e
        puts "   ERROR: No valid parser for RSS feed format"
        puts "   This might happen if the RSS feed URL is returning HTML or an invalid XML format"
        puts "   Feed URL: #{src['rss_url']}"
        return
      rescue => e
        puts "   ERROR: Failed to parse RSS feed: #{e.message}"
        puts "   #{e.class}"
        return
      end
    end

    def extract_first_paragraph(html_content)
      return '' if html_content.nil? || html_content.strip.empty?
      # Remove HTML tags first
      text = html_content.gsub(/<[^>]*>/, ' ').strip
      # Get first sentence or first 500 chars, whichever is shorter
      first_sentence = text.split(/[.!?]\s+/).first || text
      first_sentence.length > 500 ? first_sentence[0..500] : first_sentence
    end

    def clean_text(text)
      return '' if text.nil? || text.strip.empty?
      # Strip HTML tags aggressively
      clean = text.gsub(/<[^>]*>/, ' ')
      # Decode common HTML entities
      clean = clean.gsub(/&nbsp;/, ' ').gsub(/&amp;/, '&').gsub(/&lt;/, '<').gsub(/&gt;/, '>').gsub(/&quot;/, '"').gsub(/&#39;/, "'")
      # Remove extra whitespace
      clean = clean.gsub(/\s+/, ' ').strip
      # HARD LIMIT to 150 characters for card descriptions
      if clean.length > 150
        # Try to cut at a word boundary
        truncated = clean[0..150]
        last_space = truncated.rindex(' ')
        truncated = truncated[0..last_space] if last_space && last_space > 100
        truncated.strip + '...'
      else
        clean
      end
    end

    def process_entries(site, src, entries)
      entries.each do |e|
        puts "...fetching #{e.url}"
        
        # Extract tags/categories from the feed entry if available
        tags = []
        categories = []
        
        if e.respond_to?(:categories) && e.categories
          tags = e.categories.is_a?(Array) ? e.categories : [e.categories]
        end
        
        if e.respond_to?(:tags) && e.tags
          tags += e.tags.is_a?(Array) ? e.tags : [e.tags]
        end
        
        # Get summary - prefer e.summary, but if not available extract from content
        raw_summary = e.summary
        if raw_summary.nil? || raw_summary.strip.empty?
          # Extract first paragraph or sentence from content as fallback
          raw_summary = extract_first_paragraph(e.content) if e.content
        end
        
        # Clean and limit the summary to max 200 chars
        clean_summary = clean_text(raw_summary) if raw_summary
        
        create_document(site, src['name'], e.url, {
          title: e.title,
          content: e.content,
          summary: clean_summary,
          published: e.published,
          tags: tags.uniq,
          categories: categories
        })
      end
    end

    def create_document(site, source_name, url, content)
      # check if title is composed only of whitespace or foreign characters
      if content[:title].gsub(/[^\w]/, '').strip.empty?
        # use the source name and last url segment as fallback
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}"
      else
        # parse title from the post or use the source name and last url segment as fallback
        slug = content[:title].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}" if slug.empty?
      end

      path = site.in_source_dir("_posts/#{slug}.md")
      doc = Jekyll::Document.new(
        path, { :site => site, :collection => site.collections['posts'] }
      )
      doc.data['external_source'] = source_name
      doc.data['title'] = content[:title]
      # Ensure description is short and clean for the blog card
      doc.data['description'] = content[:summary] || ''
      doc.data['date'] = content[:published]
      doc.data['redirect'] = url  # Link directly to the external article
      doc.data['tags'] = content[:tags] || []
      doc.data['categories'] = content[:categories] || ['external-posts']
      
      # Set minimal content since we're redirecting
      doc.content = "This post is available on [#{source_name}](#{url})."
      
      site.collections['posts'].docs << doc
    end
    

    def fetch_from_urls(site, src)
      src['posts'].each do |post|
        puts "...fetching #{post['url']}"
        content = fetch_content_from_url(post['url'])
        content[:published] = parse_published_date(post['published_date'])
        create_document(site, src['name'], post['url'], content)
      end
    end

    def parse_published_date(published_date)
      case published_date
      when String
        Time.parse(published_date).utc
      when Date
        published_date.to_time.utc
      else
        raise "Invalid date format for #{published_date}"
      end
    end

    def fetch_content_from_url(url)
      html = HTTParty.get(url).body
      parsed_html = Nokogiri::HTML(html)

      title = parsed_html.at('head title')&.text.strip || ''
      description = parsed_html.at('head meta[name="description"]')&.attr('content')
      description ||= parsed_html.at('head meta[name="og:description"]')&.attr('content')
      description ||= parsed_html.at('head meta[property="og:description"]')&.attr('content')

      body_content = parsed_html.search('p').map { |e| e.text }
      body_content = body_content.join() || ''

      {
        title: title,
        content: body_content,
        summary: description
        # Note: The published date is now added in the fetch_from_urls method.
      }
    end

  end
end
