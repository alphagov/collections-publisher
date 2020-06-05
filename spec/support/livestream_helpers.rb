def stub_todays_youtube_link
  stub_request(:get, todays_link)
end

def stub_yesterdays_youtube_link
  stub_request(:get, yesterdays_link)
end

def yesterdays_link
  coronavirus_content_json.dig("details", "live_stream", "video_url")
end

def yesterdays_date
  coronavirus_content_json.dig("details", "live_stream", "date")
end

def todays_link
  "https://www.youtube.com/watch?todays_link"
end
