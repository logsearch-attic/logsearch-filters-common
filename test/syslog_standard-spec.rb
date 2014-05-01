require "test_utils"
require "logstash/filters/grok"

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  config <<-CONFIG
    filter {
      #{File.read("target/10-syslog_standard.conf")}
    }
  CONFIG

  describe "Accepting standard syslog message without PID specified" do
    sample("@type" => "syslog", "host" => "1.2.3.4:12345", "@message" => '<85>Apr 24 02:05:03 localhost sudo: bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@type"] } == 'syslog'
      insist { subject["@timestamp"] } == Time.iso8601("2014-04-24T02:05:03.000Z")
      insist { subject['@source.host'] } == '1.2.3.4'

      insist { subject['syslog_facility'] } == 'security/authorization'
      insist { subject['syslog_facility_code'] } == 10
      insist { subject['syslog_severity'] } == 'notice'
      insist { subject['syslog_severity_code'] } == 5
      insist { subject['syslog_program'] } == 'sudo'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['syslog_message'] } == 'bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd'
    end
  end

  describe "Accepting standard syslog message with PID specified" do
    sample("@type" => "relp", "host" => "1.2.3.4", "@message" => '<78>Apr 24 04:03:06 localhost crontab[32185]: (root) LIST (root)') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@type"] } == 'relp'
      insist { subject["@timestamp"] } == Time.iso8601("2014-04-24T04:03:06.000Z")
      insist { subject['@source.host'] } == '1.2.3.4'

      insist { subject['syslog_facility'] } == 'clock'
      insist { subject['syslog_facility_code'] } == 9
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'crontab'
      insist { subject['syslog_pid'] } == '32185'
      insist { subject['syslog_message'] } == '(root) LIST (root)'
    end
  end

  describe "Accepting Cloud Foundry syslog message with valid host" do
    sample("@type" => "syslog", "host" => "1.2.3.4", "@message" => '<14>2014-04-23T23:19:01.227366+00:00 172.31.201.31 vcap.nats [job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@type"] } == 'syslog'
      insist { subject["@timestamp"] } == Time.iso8601("2014-04-23T23:19:01.227Z")
      insist { subject['@source.host'] } == '172.31.201.31'

      insist { subject['syslog_facility'] } == 'user-level'
      insist { subject['syslog_facility_code'] } == 1
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'vcap.nats'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['syslog_message'] } == '[job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}'
    end
  end

  describe "Invalid syslog message" do
    sample("@type" => "syslog", "host" => "1.2.3.4", "@message" => '<78>Apr 24, this message should fail') do
      insist { subject["tags"] } == [ '_grokparsefailure-syslog_standard' ]
      insist { subject["@type"] } == 'syslog'
    end
  end

end
