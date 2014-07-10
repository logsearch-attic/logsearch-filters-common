require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'Filters behave when combined' do

    config <<-CONFIG
      filter {
        #{File.read('target/logstash.filters.conf')}
      }
    CONFIG

    #NB - this currently fails because the combine order is incorrect"
    sample("@type" => "syslog", "@message" => '<13>1 2014-06-23T10:54:42.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:42" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\my-json-log.log" host="SOURCE-HOSTNAME" service="MyService" type="json"] {"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}') do
      #puts subject.to_yaml

      insist { subject['tags'] } == [ 'syslog_standard' ]
      insist { subject['@type'] } === 'json'
      insist { subject['@timestamp'] } == Time.iso8601('2014-02-04T23:45:12.000Z')

      insist { subject['level'] } === 'WARN'
      insist { subject['timestamp'] } === '2014-02-04T23:45:12.000Z'
      insist { subject['logger'] } === 'I.am.a.JSON.logger'
      insist { subject['method'] } === 'testMe'
      insist { subject['message'] } === 'plain message accepted here.'
    end

  end

end
