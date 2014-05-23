require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'json' do

    config <<-CONFIG
      filter {
        #{File.read('target/10-json.conf')}
      }
    CONFIG

    sample('@type' => 'json', '@message' => '{"@timestamp":"2014-04-02T16:49:19.332Z","string":"foobar","number": 4.2}') do
      insist { subject['tags'] }.nil?
      insist { subject['@type'] } === 'json'
      insist { subject['@timestamp'] } == Time.iso8601('2014-04-02T16:49:19.332Z')

      insist { subject['string'] } === 'foobar'
      insist { subject['number'] } === 4.2
    end

  end

end
