require "test_utils"
require "logstash/filters/grok"
require "json"

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe "nxlog_standard" do

    config <<-CONFIG
      filter {
        #{File.read("target/10-syslog_standard.conf")}
        #{File.read("target/20-nxlog_standard.conf")}
      }
    CONFIG

    sample("@type" => "syslog", "@message" => '<13>1 2014-06-23T09:54:13.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:13" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log" host="SOURCE-HOSTNAME" service="TradingAPI_IIS" type="iis_tradingapi"] 2014-06-23 08:53:46 W3SVC1 SOURCE-HOSTNAME 172.16.68.7 GET /tradingapi - 81 - 172.16.68.245 HTTP/1.0 - - - dns.name.co.uk 200 0 0 2923 106 46') do
      insist { subject["@type"] } == "iis_tradingapi"
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2014-06-23T08:54:13.275Z")

      insist { subject['@message'] } == "2014-06-23 08:53:46 W3SVC1 SOURCE-HOSTNAME 172.16.68.7 GET /tradingapi - 81 - 172.16.68.245 HTTP/1.0 - - - dns.name.co.uk 200 0 0 2923 106 46"
      insist { subject['@shipper'] } == {
        "pid" => "14506",
        "host" => "SHIPPER-HOSTNAME",
        "event_received_time" => "2014-06-23 09:54:13",
        "module_name" => "in1",
        "module_type" => "im_file"
      }
      insist { subject['@source'] } == {
        "path" => "\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log",
        "host" => "SOURCE-HOSTNAME",
        "service" => "TradingAPI_IIS"
      }
    end

  end

end
