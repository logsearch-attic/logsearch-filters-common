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

  describe "The actual log event is parsed according to the internal [NXLOG@14506 type=nginx_combined]" do

    config <<-CONFIG
      filter {
        #{File.read("target/10-syslog_standard.conf")}
        #{File.read("target/20-nxlog_standard.conf")}
        #{File.read("target/75-nginx_combined.conf")}
      }
    CONFIG

    actual_nginx_event = '192.0.2.15 - - [06/Jun/2013:07:28:33 +0000] "GET /favicon.ico HTTP/1.1" 200 0 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36"'
    nxlog_wrapped_event = '<13>1 2014-06-23T09:54:13.275897+01:00 SHIPPER-HOSTNAME - - - ' \
                        + '[NXLOG@14506 EventReceivedTime="2014-06-23 09:54:13" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log" host="SOURCE-HOSTNAME" service="nginx" type="nginx_combined"] ' \
                        + actual_nginx_event
    
    sample("@type" => "syslog", "@message" => nxlog_wrapped_event) do
      insist { subject["@message"] } == actual_nginx_event
    end

    # @type should be the type of the embedded event, not the nxlog/syslog "wrapper"
    sample("@type" => "syslog", "@message" => nxlog_wrapped_event) do
      insist { subject["@type"] } == "nginx_combined"
    end

    # @timestamp should be the timestamp of the embedded log event, not the nxlog/syslog "wrapper"
    sample("@type" => "syslog", "@message" => nxlog_wrapped_event) do
      insist { subject["@timestamp"] } == Time.iso8601("2013-06-06T07:28:33.000Z")
    end

    # @source info should come from [NXLOG@14506 ... ]
    sample("@type" => "syslog", "@message" => nxlog_wrapped_event) do
      insist { subject['@source']['path'] } == "\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log"
      insist { subject['@source']['host'] } == "SOURCE-HOSTNAME"
      insist { subject['@source']['service'] } == "nginx"
    end

    # And the actual event log should be parsed correctly
    sample("@type" => "syslog", "@message" => nxlog_wrapped_event) do
      insist { subject["tags"] } == [ 'syslog_standard', 'nginx' ]
      insist { subject["@timestamp"] } == Time.iso8601("2013-06-06T07:28:33.000Z")
      insist { subject['remote_addr'] } == '192.0.2.15'
      insist { subject['remote_user'] } == '-'
      insist { subject['request_method'] } == 'GET'
      insist { subject['request_uri'] } == '/favicon.ico'
      insist { subject['request_httpversion'] } == '1.1'
      insist { subject['status'] } == '200'
      insist { subject['body_bytes_sent'] } == '0'
      insist { subject['http_referer'] }.nil?
      insist { subject['http_user_agent'] } == '"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36"'
    end

  end


  describe "NXLOG parser doesn't gobble part of the message" do

    config <<-CONFIG
      filter {
        #{File.read("target/10-syslog_standard.conf")}
        #{File.read("target/20-nxlog_standard.conf")}
      }
    CONFIG

    nxlog_syslog_prefix = '<13>1 2014-06-23T09:54:13.275897+01:00 SHIPPER-HOSTNAME - - - ' \
                        + '[NXLOG@14506 EventReceivedTime="2014-06-23 09:54:13" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log" host="SOURCE-HOSTNAME" service="SOURCE_SERVICE" type="SOURCE_HOST"]'

    sample("@type" => "syslog", "@message" => "#{nxlog_syslog_prefix} 14:17:23.012 [RingBufferThread - default.priceMarket.impl.MTMarketPricing:0] INFO  S.C.Micros.PostThrottlePublication - (tupleid=0,count=3,avg=795,max=1838)") do
      insist { subject['@message'] } == "14:17:23.012 [RingBufferThread - default.priceMarket.impl.MTMarketPricing:0] INFO  S.C.Micros.PostThrottlePublication - (tupleid=0,count=3,avg=795,max=1838)"  
    end

    sample("@type" => "syslog", "@message" => "#{nxlog_syslog_prefix} INFO  2014-06-26 14:12:09,582 34 ObjectPooling.Pool`1+IItemStore[[ActiveMQPubSub.ActiveMQConnectionPool.IActiveMQPooledConnection, ActiveMQPubSub, Version=1.49.0.0, Culture=neutral, PublicKeyToken=null]] Number of pooled objects in use 1") do
      insist { subject['@message'] } == "INFO  2014-06-26 14:12:09,582 34 ObjectPooling.Pool`1+IItemStore[[ActiveMQPubSub.ActiveMQConnectionPool.IActiveMQPooledConnection, ActiveMQPubSub, Version=1.49.0.0, Culture=neutral, PublicKeyToken=null]] Number of pooled objects in use 1"  
    end
  end

end
