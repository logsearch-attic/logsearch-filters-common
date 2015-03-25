## Status

![Lifecycle: retired](https://img.shields.io/badge/lifecycle-retired-blue.svg) ![Support: unsupported](https://img.shields.io/badge/support-unsupported-yellow.svg)

The functionality in this project has been merged into the core [logsearch-boshrelease](https://github.com/logsearch/logsearch-boshrelease) as of v19.  This project has thus been retired and is no longer active or supported.

* if you should choose to fork it, please let us know so we can link to your project

---

This is a collection of common logstash filters for the logsearch project. It
also contains some reusable scripts for testing filters in other repositories.


## Conventions

 * your logstash filters go in `src`...
    * they can be plain configuration files named `*.conf`, or
    * they can be dynamic, ERB files named `*.conf.erb`
 * your tests for those filters should go into `test`...
    * they should be rspec tests and named `*spec.rb`


## Setup

First, make sure you have [java](http://www.java.com/) installed. Then, clone
the repository...

    $ git clone https://github.com/logsearch/logsearch-filters-common.git
    $ cd logsearch-filters-common

Install the dependencies (logstash source + deps)...

    $ ./bin/install_deps.sh 1.3.0

Build the filters and run the tests...

    $ ./bin/build.sh && ./bin/test.sh
    .

    Finished in 0.18 seconds
    1 example, 0 failures


## Reuse

The install_deps/build/test scripts are intended to be reusable. If you want to
create a separate repository of rules, you could add this as a submodule.

    $ git submodule add https://github.com/logsearch/logsearch-filters-common.git vendor/logsearch-filters-common

With the following, your repository-specific scripts take precedence, but
otherwise these shared scripts are used. For example, you could customize your
`build.sh` to create your filters differently, but still use the shared
`test.sh` script.

    $ export PATH=$PWD/bin:$PWD/vendor/logsearch-filters-common/bin:$PATH

Then you easily have a one-liner to install/build/test everything.

    $ install_deps.sh && build.sh && test.sh
