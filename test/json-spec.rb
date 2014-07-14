require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'json' do

    config <<-CONFIG
      filter {
        #{File.read('snippets/json.conf')}
      }
    CONFIG

    sample('@message' => '{"@timestamp":"2014-04-02T16:49:19.332Z","string":"foobar","number": 4.2}') do
      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } == Time.iso8601('2014-04-02T16:49:19.332Z')

      insist { subject['string'] } === 'foobar'
      insist { subject['number'] } === 4.2
    end

    sample('@message' => '{"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}') do
      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } == Time.iso8601('2014-02-04T23:45:12.000Z')

      insist { subject['level'] } === 'WARN'
      insist { subject['timestamp'] } === '2014-02-04T23:45:12.000Z'
      insist { subject['logger'] } === 'I.am.a.JSON.logger'
      insist { subject['method'] } === 'testMe'
      insist { subject['message'] } === 'plain message accepted here.'
    end

    sample('@message' => '{"level":"INFO","timestamp":"2014-02-05T12:34:56.000Z","logger":"I.am.a.JSON.logger","method":"testMe","line":"17","thread":"Loop 1","message":{"Message":"Quote has been accepted.","Items":{"FirstArg":{"Inner value":null,"Secondary value":null},"TypeId":1,"ClientUserId":234,"InternalUserId":56789,"MarketId":123,"Reference":null,"SessionId":"01234567-89ab-cdef-abcd-ef0123456789","SourceId":9,"TradingAccountId":12345}}}') do
      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } == Time.iso8601('2014-02-05T12:34:56.000Z')

      insist { subject['level'] } === 'INFO'
      insist { subject['timestamp'] } === '2014-02-05T12:34:56.000Z'
      insist { subject['logger'] } === 'I.am.a.JSON.logger'
      insist { subject['method'] } === 'testMe'
      insist { subject['line'] } === '17'
      insist { subject['thread'] } === 'Loop 1'
      insist { subject['message'] }.nil?
      insist { subject['message_data'] }.is_a? Hash
      insist { subject['message_data']['Message'] } === 'Quote has been accepted.'
      insist { subject['message_data']['Items']['TypeId'] } === 1
    end

    sample('@message' => '{"@timestamp":["2014-05-29T00:24:38.557Z","2014-05-29T00:24:38.558Z"],"message":"anything"}') do
      insist { subject['tags'] } == [ '_timestamperror' ]
      insist { subject['@timestamp'] }.class == Time
      insist { subject['_timestamperror'] } == [ '2014-05-29T00:24:38.557Z', '2014-05-29T00:24:38.558Z' ]

      insist { subject['message'] } == 'anything'
    end

    # simple test to make sure logstash behaves how it's supposed to and the
    # date filter doesn't error on non-matching data [in `timestamp`]
    sample('@message' => '{"timestamp":["2014-05-29T00:24:38.557Z","2014-05-29T00:24:38.558Z"],"message":"anything"}') do
      insist { subject['@timestamp'] }.class == Time
      insist { subject['timestamp'] } == [ '2014-05-29T00:24:38.557Z', '2014-05-29T00:24:38.558Z' ]

      insist { subject['message'] } == 'anything'
    end

  end

end
