---
title: "Starting a New Environment"
---

We treat a `logsearch-filters` environment is a collection of filters intended for a particular deployment. They'll
typically include logstash filters config, Kibana dashboards, and 


## Directory Structure

A typical environment will look like the following...

    bin/             # frequently used commands
                     #   e.g. compile, install, test, upstream-reload
    docs/            # documentation for installation, development, deployment
    src/             # raw sources for logstash filters, dashboards, etc
    target/          # artifacts from building src/
    test/            # unit/integration tests
    upstream/        # committed filter components from upstream providers
                     #   e.g. logsearch/filters-common, logsearch/filters-cloudfoundry

You can use the following to create a new environment...

    mkdir {bin,docs,src,target,test,upstream}


## The `bin/` files

We usually have several commands in here...

 * `bin/compile` - responsible for creating usable configurations and dumping them into your `target/` directory for
   testing or usage. Most of our filters are ERB files, so we simply run several `erb {in} > {out}` commands here.
 * `bin/install` - responsible for installing all the development and build tools your environment needs. This will
   usually include at least logstash (and jruby).
 * `bin/test` - responsible for executing your tests against the build artifacts. Most of our filters are using rspec.
 * `bin/upstream-reload` - responsible for (re)downloading any `upstream/` artifacts. Typically only used when upgrading
   upstream versions.

As a starting point for your new environment, you may want to use the scripts from `logsearch/filters-common:bin/`.


## The `upstream/` files

We have several environment repos which are deployment-specific (e.g. for Cloud Foundry). When we want to reuse those
alongside our own internal filters repo, we commit the upstream build artifacts here. For each directory here, we'll
usually have a corresponding section in `bin/upstream-reload` which looks something like...

    [ ! -f upstream/cloudfoundry ] || rm -fr cloudfoundry
    mkdir upstream/cloudfoundry
    wget -qO- https://github.com/logsearch/filters-cloudfoundry/releases/download/v0.1.1/artifacts.tar.gz \
      | tar -xzf --strip-components 1 -C upstream/cloudfoundry


## Everything else

The contents of the remaining directories (`src/`, `target/`, `test/`) should be structured in whatever way makes the
most sense for your source code. Typically the three directories have the same, or very similar, structure. Below are a
couple different approaches.

With our `logsearch/filters-common` repository, where it's just a collection of deployment-agnostic, reusable snippets,
we use a fairly straightforward approach...

    logstash/                 # everything related to logstash
        snippets/             # small, standalone filters intended to be recomposed elsewhere
        *.conf                # integrated configurations which could be independently used
    kibana-dashboards/        # sample kibana dashboards

With our internal filters repository we can focus on splitting components by application usage. For example...

    api/                                  # our API service
        kibana-dashboards/                # the service-specific dashboards we maintain
            slow-transactions.json
            api-client-behavior.json
        logstash-filters/                 # the log format-specific logstash filter rules
            proxy-v1.conf
            execute-v1.conf
            execute-v2.conf
    authentication/                       # another similarly structured service
        ...
    ...
