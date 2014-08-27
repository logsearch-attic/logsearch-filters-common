require "test_utils"
require "logstash/filters/grok"

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe "apache_combined" do

    config <<-CONFIG
      filter {
        #{File.read("src/logstash/snippets/apache_combined.conf")}
      }
    CONFIG

    sample("@message" => '192.168.0.39 - - [31/Jul/2014:07:25:53 -0500] "GET /spread-betting/wp-includes/js/jquery/jquery.js?ver=1.11.0 HTTP/1.1" 200 96402 "http://origin-www.cityindex.co.uk/spread-betting/" "GomezAgent 2.0"') do

      insist { subject["@timestamp"] } == Time.iso8601("2014-07-31T12:25:53.000Z")

      insist { subject['clientip'] } == '192.168.0.39'
      insist { subject['ident'] } == '-'
      insist { subject['auth'] } == '-'
      insist { subject['timestamp'] } == '31/Jul/2014:07:25:53 -0500'
      insist { subject['verb'] } == 'GET'
      insist { subject['request'] } == '/spread-betting/wp-includes/js/jquery/jquery.js?ver=1.11.0'
      insist { subject['httpversion'] } === '1.1'
      insist { subject['response'] } === 200
      insist { subject['bytes'] } === 96402
      insist { subject['referrer'] } === "\"http://origin-www.cityindex.co.uk/spread-betting/\""
      insist { subject['agent'] } == '"GomezAgent 2.0"'

      insist { subject.to_hash.keys.sort } == [
        "@message",
        "@timestamp",
        "@version",
        "agent",
        "auth",
        "bytes",
        "clientip",
        "httpversion",
        "ident",
        "referrer",
        "request",
        "response",
        "timestamp",
        "verb",
      ]

    end

    sample("@message" => '192.168.1.42 - - [31/Jul/2014:07:26:51 -0500] "GET /spread-betting/ HTTP/1.1" 200 32938 "-" "msnbot-UDiscovery/2.0b (+http://search.msn.com/msnbot.htm)"') do

      insist { subject["@timestamp"] } == Time.iso8601("2014-07-31T12:26:51.000Z")

      insist { subject['clientip'] } == '192.168.1.42'
      insist { subject['ident'] } == '-'
      insist { subject['auth'] } == '-'
      insist { subject['timestamp'] } == '31/Jul/2014:07:26:51 -0500'
      insist { subject['verb'] } == 'GET'
      insist { subject['request'] } == '/spread-betting/'
      insist { subject['httpversion'] } === '1.1'
      insist { subject['response'] } === 200
      insist { subject['bytes'] } === 32938
      insist { subject['referrer'] } === "\"-\""
      insist { subject['agent'] } == '"msnbot-UDiscovery/2.0b (+http://search.msn.com/msnbot.htm)"'

      insist { subject.to_hash.keys.sort } == [
        "@message",
        "@timestamp",
        "@version",
        "agent",
        "auth",
        "bytes",
        "clientip",
        "httpversion",
        "ident",
        "referrer",
        "request",
        "response",
        "timestamp",
        "verb",
      ]

    end

  end

end
