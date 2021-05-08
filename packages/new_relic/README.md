# new_relic

Instrument Dart on the Server with New Relic.

This work with the [New Relic C SDK](https://docs.newrelic.com/docs/agents/c-sdk/get-started/introduction-c-sdk) bound to Dart, and is expected to be used with a Dart server running in a Docker container. The New Relic daemon (which transmit the collected data to New Relic every 5 seconds) should be running in an adjacent container.

## Getting Started

Copy `.env.example` to `.env` and fill in your configuration.

Then run the sample with:

```
docker-compose up
```
