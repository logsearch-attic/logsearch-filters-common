---
title: "Parsing a New Log Format"
---

Assume you need to parse a new log format for your internal "Tibco RVD" service. The first step will be to create a
branch for your work. Give it a name related to the changes you want to make.

    myfilters$ git checkout -b add-tibco_rvd-parser

When writing parsers, you may find the following resources particularly helpful:

 * [Logstash Documentation](http://logstash.net/docs/1.4.2/) - the **Filters** section will be most useful to you (e.g.
   [csv](http://logstash.net/docs/1.4.2/filters/csv),
   [date](http://logstash.net/docs/1.4.2/filters/date),
   [grok](http://logstash.net/docs/1.4.2/filters/grok),
   [json](http://logstash.net/docs/1.4.2/filters/json),
   [kv](http://logstash.net/docs/1.4.2/filters/kv),
   [mutate](http://logstash.net/docs/1.4.2/filters/mutate))
 * `grok` - the main method for parsing messages
    * [Rule Debugger](http://grokdebug.herokuapp.com/) - interactively test your
      [grok](http://logstash.net/docs/1.4.2/filters/grok) rules
    * [Pre-Defined Patterns](https://github.com/elasticsearch/logstash/blob/master/patterns/grok-patterns) -
      you can use these terms in your grok matching
 * [Examples](https://github.com/logsearch/logsearch-filters-common/tree/master/src/logstash/snippets/) -
   sometimes it's easier to see how another parser does it

As an example, let's create the `tibco_rvd` parser. The first step is to make sure you have examples of the log messages
to work with. Here are a couple examples:

    2014-04-09 16:20:43 D:\Apps\Tibco\tibrv\8.1\bin\rvd_original.exe: TIB/Rendezvous Error: {ADV_CLASS="ERROR" ADV_SOURCE="SYSTEM" ADV_NAME="DATALOSS.INBOUND.BCAST" ADV_DESC="dataloss: remote daemon did not satisfy our retransmission request(s)" host="192.0.2.1" lost=99}
    2014-04-09 15:48:16 D:\Apps\Tibco\tibrv\8.1\bin\rvd_original.exe: TIB/Rendezvous Error: {ADV_CLASS="ERROR" ADV_SOURCE="SYSTEM" ADV_NAME="DATALOSS.INBOUND.BCAST" ADV_DESC="dataloss: remote daemon already timed out the data" host="192.0.2.100" lost=480}

When getting started with a new parser, it's a good idea to create a draft of what you want the parsed log message to
look like. For `tibco_rvd`, we'd like the messages to be indexed and searchable as:

    {
      "@message": "2014-04-09 16:20:43 D:\\Apps\\Tibco\\tibrv\\8.1\\bin\\rvd_original.exe: TIB/Rendezvous Error: {ADV_CLASS=\"ERROR\" ADV_SOURCE=\"SYSTEM\" ADV_NAME=\"DATALOSS.INBOUND.BCAST\" ADV_DESC=\"dataloss: remote daemon did not satisfy our retransmission request(s)\" host=\"192.0.2.1\" lost=99}",
      "@timestamp": "2014-04-09T15:20:43.000Z",
      "@type": "tibco_rvd",
      "@version": "1",
      "data": {
        "ADV_CLASS": "ERROR",
        "ADV_DESC": "dataloss: remote daemon did not satisfy our retransmission request(s)",
        "ADV_NAME": "DATALOSS.INBOUND.BCAST",
        "ADV_SOURCE": "SYSTEM",
        "host": "192.0.2.1",
        "lost": 99
      },
      "datetime": "2014-04-09 16:20:43",
      "message": "TIB/Rendezvous Error",
      "rvd_path": "D:\\Apps\\Tibco\\tibrv\\8.1\\bin\\rvd_original.exe",
      "tags": []
    }

Since you already know the desired result, it's usually easiest to create the tests based off those results. Then you're
able to re-run the tests as you're updating the parser, with each change hopefully finishing more of your tests. For a
test file, create a new file in `test`. Be sure to name it with your new log type (e.g. `tibco_rvd`), suffixed with
`-spec.rb`.

    myfilters$ vim test/tibco_rvd-spec.rb

 > *Tip*: Use your favourite text editor in place of `vim`

Your test file will look something like this (make sure you replace `tibco_rvd` if you're using this as a template):

    require "test_utils"
    require "logstash/filters/grok"

    describe LogStash::Filters::Grok do
      extend LogStash::RSpec

      describe "tibco_rvd" do
        config <<-CONFIG
          filter {
            #{File.read("target/50-tibco_rvd.conf")}
          }
        CONFIG

        #
        # your testing scenarios will go here
        #

      end
    end

Now you can add multiple testing scenarios to cover the various circumstances your parser sees. In each case, you'll
create a `sample` which says that it's testing a `tibco_rvd` message and includes the raw `@message`. The test runner
will run `@message` through the parser, and then you're able to `insist` that each particular field has the result you
expect. Here's an example using the first sample log message from above:

    sample("@type" => "tibco_rvd", "@message" => '2014-04-09 16:20:43 D:\Apps\Tibco\tibrv\8.1\bin\rvd_original.exe: TIB/Rendezvous Error: {ADV_CLASS="ERROR" ADV_SOURCE="SYSTEM" ADV_NAME="DATALOSS.INBOUND.BCAST" ADV_DESC="dataloss: remote daemon did not satisfy our retransmission request(s)" host="192.0.2.1" lost=99}') do
      insist { subject["tags"] } == []
      insist { subject["@type"] } === "tibco_rvd"
      insist { subject["@timestamp"] } === Time.iso8601("2014-04-09T15:20:43Z")

      insist { subject["datetime"] } === "2014-04-09 16:20:43"
      insist { subject["rvd_path"] } === "D:\\Apps\\Tibco\\tibrv\\8.1\\bin\\rvd_original.exe"
      insist { subject["message"] } === "TIB/Rendezvous Error"
      insist { subject["dataraw"] }.nil?
      insist { subject["data"]["ADV_CLASS"] } === "ERROR"
      insist { subject["data"]["ADV_SOURCE"] } === "SYSTEM"
      insist { subject["data"]["ADV_NAME"] } === "DATALOSS.INBOUND.BCAST"
      insist { subject["data"]["ADV_DESC"] } === "dataloss: remote daemon did not satisfy our retransmission request(s)"
      insist { subject["data"]["host"] } === "192.0.2.1"
      insist { subject["data"]["lost"] } === 99
    end

 > **Tip**: use strict comparisons (`===`) instead of loose comparisons (`==`). This way the test will error if the
 > types are wrong (e.g. sending a string instead of an integer could cause problems in your Kibana dashboards later).

You can give it a try by running `./bin/build.sh && ./bin/test.sh`, but don't be surprised when it fails. After each
addition or change to your parser, you'll be able to re-run it and see it make a little more progress through your
tests.

Now let's get started with the actual parser rules. For a new parser, create a file in `src`. Be sure to prefix it with
`50-`, followed by your new log type (e.g. `tibco_rvd`), suffixed with `.conf`.

    myfilters$ vim src/50-tibco_rvd.conf

To start, all configuration files must look like the following (make sure you replace `tibco_rvd` if you're using this
as a template):

    if [@type] == "tibco_rvd" {
      #
      # your parsing rules will go here
      #
    }

You'll typically start with [`grok`](http://logstash.net/docs/1.4.2/filters/grok) to separate the main fields. With
`tibco_rvd`, the format looks roughly like `{date} {rvd_path}: {message}: {rawdata}`. As the first filter in our
configuration file, the `grok` pattern is a bit more verbose:

{% raw %}
    grok {
      match => [ "@message", "%{TIMESTAMP_ISO8601:datetime} (?<rvd_path>[A-Z]:[^:]+): (?<message>[^:]+): {%{GREEDYDATA:dataraw}}" ]
    }
{% endraw %}

 > **Tip**: Sometimes the `grok` rules are a bit difficult to figure out. If you're having trouble, you might want to
 > use the [debugger](http://grokdebug.herokuapp.com/). If it's not matching what you expect, remove patterns from the
 > end until it does, then work back at adding and fixing the patterns one by one.

You'll typically add the [`date`](http://logstash.net/docs/1.4.2/filters/date) filter after `grok` so it knows when the
event actually happened. Be sure to specify which field and what format the date is in. We also include the timezone
which helps correct for standard/daylight time changes since this log format does not explicitly include a timezone.

    date {
      match => [ "datetime", "YYYY-MM-dd HH:mm:ss" ]
      timezone => "Europe/London"
    }

The `tibco_rvd` format also has some key-value-like pairs in the last field. We can extract them into an object to make
search easier. We'll use the [`kv`](http://logstash.net/docs/1.4.2/filters/kv) filter to put the key-value pairs inside
the `data` field:

    kv {
      source => "dataraw"
      field_split => ", "
      target => "data"
      remove_field => [ "dataraw" ]
    }

Looking at the sample log messages, it seems like the `lost` field in our `data` should be an integer. By default, all
the fields are strings, but by converting it we'll be able to create numeric-based graphs in Kibana. We'll add another
`mutate` filter for the conversion.

    mutate {
      convert => [ "[data][lost]", "integer" ]
    }

 > **Warning**: you should only convert fields to non-strings if they will be exclusively that type. Otherwise messages
 > may error and get dropped if it's trying to put a string into an integer field.

Hopefully you've been re-running the tests after each step, but by now all the tests (including the newest one) should
be running successfully:

    myfilters$ ./bin/build.sh && ./bin/test.sh 
    compiling src/50-iis_tradingapi.conf.erb...
    ...................

    Finished in 0.797 seconds
    19 examples, 0 failures

To finish things up, you'll need to add your changes to the repository:

    myfilters$ git add src/50-tibco_rvd.conf test/tibco_rvd-spec.rb

It's always a good idea to double check your changes, look for embarrassing typos, and make sure you haven't forgotten
any `@todo` reminders:

    myfilters$ git diff --cached

Once it all looks good, go ahead and commit it. If your work is related to a ticket or issue, be sure to include that in
the commit message. Once committed, push your new branch out:

    myfilters$ git commit -m 'Add the tibco_rvd parser /issue #7'
    myfilters$ git push origin add-tibco_rvd-parser

Finally, you should let everyone know your parser is ready by creating a pull request so others on the team review your
changes before merging them in for a release.
