require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'elasticsearch_request' do

    config <<-CONFIG
      filter {
        #{File.read('target/75-elasticsearch_request.conf')}
      }
    CONFIG

    #sample('@type' => 'elasticsearch_request', '@message' => '{"time":"2014-04-02T16:49:19.332Z","starttime":"2014-04-02T16:49:18.684Z","localaddr":"127.0.0.1","localport":9200,"remoteaddr":"127.0.0.1","remoteport":46082,"scheme":"http","method":"POST","path":"/logstash-2014.04.02/_search","querystr":"timeout=15s","code":200,"status":"OK","size":672,"duration":648,"year":"2014","month":"04","day":"02","hour":"16","minute":"49","dow":"Wed","cluster":"live-logsearch"}') do
    sample('@type' => 'elasticsearch_request', '@message' => '{"time":"2014-04-02T16:49:19.332Z","starttime":"2014-04-02T16:49:18.684Z","localaddr":"127.0.0.1","localport":9200,"remoteaddr":"127.0.0.1","remoteport":46082,"scheme":"http","method":"POST","path":"/logstash-2014.04.02/_search","querystr":"timeout=15s","code":200,"status":"OK","size":672,"duration":648,"year":"2014","month":"04","day":"02","hour":"16","minute":"49","dow":"Wed","cluster":"live-logsearch","data":"{\"facets\":{\"terms\":{\"terms_stats\":{\"value_field\":\"TotalMs\",\"key_field\":\"ProcessDesc.Status\",\"size\":10,\"order\":\"count\"},\"facet_filter\":{\"fquery\":{\"query\":{\"filtered\":{\"query\":{\"bool\":{\"should\":[{\"query_string\":{\"query\":\"*\"}}]}},\"filter\":{\"bool\":{\"must\":[{\"range\":{\"@timestamp\":{\"from\":1396453758666,\"to\":\"now\"}}},{\"fquery\":{\"query\":{\"query_string\":{\"query\":\"@environment:\\\\\"LIVE\\\\\"\"}},\"_cache\":true}},{\"fquery\":{\"query\":{\"query_string\":{\"query\":\"@type:(\\\\\"ci_ip_diagnostics_kv\\\\\")\"}},\"_cache\":true}}]}}}}}}}},\"size\":0}"}') do
      insist { subject['tags'] }.nil?
      insist { subject['@type'] } === 'elasticsearch_request'
      insist { subject['@timestamp'] } == Time.iso8601('2014-04-02T16:49:18.684Z')

      insist { subject['cluster'] } === 'live-logsearch'
      insist { subject['code'] } === 200
      insist { subject['data'] } == "{\"facets\":{\"terms\":{\"terms_stats\":{\"value_field\":\"TotalMs\",\"key_field\":\"ProcessDesc.Status\",\"size\":10,\"order\":\"count\"},\"facet_filter\":{\"fquery\":{\"query\":{\"filtered\":{\"query\":{\"bool\":{\"should\":[{\"query_string\":{\"query\":\"*\"}}]}},\"filter\":{\"bool\":{\"must\":[{\"range\":{\"@timestamp\":{\"from\":1396453758666,\"to\":\"now\"}}},{\"fquery\":{\"query\":{\"query_string\":{\"query\":\"@environment:\\\"LIVE\\\"\"}},\"_cache\":true}},{\"fquery\":{\"query\":{\"query_string\":{\"query\":\"@type:(\\\"ci_ip_diagnostics_kv\\\")\"}},\"_cache\":true}}]}}}}}}}},\"size\":0}"
      insist { subject['duration'] } === 648
      insist { subject['localaddr'] } === '127.0.0.1'
      insist { subject['localport'] } === 9200
      insist { subject['method'] } === 'POST'
      insist { subject['path'] } === '/logstash-2014.04.02/_search'
      insist { subject['querystr'] } == 'timeout=15s'
      insist { subject['remoteaddr'] } === '127.0.0.1'
      insist { subject['remoteport'] } === 46082
      insist { subject['scheme'] } === 'http'
      insist { subject['size'] } === 672
      insist { subject['starttime'] } === '2014-04-02T16:49:18.684Z'
      insist { subject['status'] } === 'OK'
      insist { subject['time'] } === '2014-04-02T16:49:19.332Z'
    
      insist { subject['day'] }.nil?
      insist { subject['dow'] }.nil?
      insist { subject['hour'] }.nil?
      insist { subject['minute'] }.nil?
      insist { subject['month'] }.nil?
      insist { subject['year'] }.nil?
    end

  end

end
