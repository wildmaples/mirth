class HttpRequest
  def self.headers(client)
    all_headers = {}
    while true
      line = client.readline
      break if line == "\r\n"
      header_name, value = line.split(": ")
      all_headers[header_name] = value
    end

    all_headers
  end
end
