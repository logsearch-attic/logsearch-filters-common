require "test_utils"
require "logstash/filters/grok"

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe "nginx_combined" do

    config <<-CONFIG
      filter {
        #{File.read("snippets/nginx_combined.conf")}
      }
    CONFIG

    sample("@message" => '192.0.2.15 - - [06/Jun/2013:07:28:33 +0000] "GET /favicon.ico HTTP/1.1" 200 0 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36"') do

      insist { subject["tags"] } == [ 'nginx' ]
      insist { subject["@timestamp"] } == Time.iso8601("2013-06-06T07:28:33.000Z")

      insist { subject['remote_addr'] } == '192.0.2.15'
      insist { subject['remote_user'] } == '-'
      insist { subject['request_method'] } == 'GET'
      insist { subject['request_uri'] } == '/favicon.ico'
      insist { subject['request_httpversion'] } == '1.1'
      insist { subject['status'] } === 200
      insist { subject['body_bytes_sent'] } === 0
      insist { subject['http_referer'] }.nil?
      insist { subject['http_user_agent'] } == '"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36"'

    end

  end

end
