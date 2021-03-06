# Zencoder

[![Build Status](https://travis-ci.org/zencoder/zencoder-ex.svg?branch=master)](https://travis-ci.org/zencoder/zencoder-ex)
[![Coverage Status](https://coveralls.io/repos/zencoder/zencoder-ex/badge.png?branch=master)](https://coveralls.io/r/zencoder/zencoder-ex?branch=master)

An Elixir library for interacting with the [Zencoder](http://zencoder.com) API.

Requires Elixir ~> 1.0.0

## Installation

Install the [Hex.pm](http://hex.pm) package

1. Add zencoder and ibrowse to your `mix.exs` dependencies:

    ```elixir
    def deps do
      [
        {:zencoder, "~> 1.0.1"},
        {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      ]
    end
    ```

2. Add `:zencoder` to your application dependencies:

    ```elixir
    def application do
      [applications: [:zencoder]]
    end
    ```

#### API Key

To communicate with the Zencoder API you'll need to provide your API key, you can find your API key by logging into your Zencoder account and visiting https://app.zencoder.com/api

There are three ways to provide your API key to the Elixir library:

1. Set it from within your application
    ```elixir
    Zencoder.api_key "your-api-key"
    ```

2. Set it as the environment variable `ZENCODER_API_KEY`
    ```
    ZENCODER_API_KEY=your-api-key iex -S mix
    ```

3. Every request takes a map as its final argument, you may provide your API key there
    ```elixir
    Zencoder.Job.progress(12345, %{api_key: "your-api-key"})
    ```

#### Base URL

By default the integration library will send all requests to version 2 of our API: "https://app.zencoder.com/api/v2". If, for whatever reason, you want to send requests to a different url you may configure your base URL in two ways:

1. Set it from within your application
    ```elixir
    Zencoder.base_url "https://app.zencoder.com/api/v1"
    ```

2. Set it as the environment variable `ZENCODER_BASE_URL`
    ```
    ZENCODER_BASE_URL=https://app.zencoder.com/api/v1 iex -S mix
    ```

#### Timeout

We recommend wrapping your requests to Zencoder in a 30 second timeout. Zencoder usually responds in less than a second, so 30 seconds should give it plenty of time to respond. If the timeout is exceeded your request will return a `%Zencoder.Error{}` struct. If you wish to customize the length of the timeout you can do so by setting the timeout (in milliseconds) in three ways:

1. Setting it from within your application
    ```elixir
    Zencoder.timeout 60000
    ```

2. Set it as the environment variable `ZENCODER_TIMEOUT`
    ```
    ZENCODER_TIMEOUT=60000 iex -S mix
    ```

3. Every request takes a map as its final argument, you may provide your custom timeout there
    ```elixir
    Zencoder.Job.progress(12345, %{timeout: 60000})
    ```

## Responses

All API request functions will return either a `%Zencoder.Response{}` struct (which may or may not be successful) or a `%Zencoder.Error{}` struct if an exception occurred.

#### %Zencoder.Response{}

A Zencoder response has the following fields:

1. body: A Map containing the parsed body of the response, or an empty map if the response body could not be parsed
2. success?: true or false depending on if the request was successful
3. code: The HTTP status code of the response
4. headers: The response headers
5. raw_body: The raw string of the response body. (Likely JSON or an empty string)
6. errors: An List of errors, or an empty List. This is a shortcut for `response.body[:errors]`

#### %Zencoder.Error{}

A Zencoder error has the following fields:

1. stacktrace: The formatted exception
2. kind:       The type of error
3. error:      The exception

Stacktrace is the formatted exception (via Exception.format/2). The kind and error are provided if you wish to do your own formatting.

#### Pattern Matching

You can pattern match to determine how to handle the response:

  ```elixir
  case Zencoder.Job.create %{test: true, input: "http://s3.amazonaws.com/zencodertesting/test.mov"} do
    %Zencoder.Response{success?: true} = response ->
      # some happy path stuff here
    %Zencoder.Response{success?: false} = response ->
      # uh oh, maybe something is wrong with your request?
      # better check the docs at https://app.zencoder.com/docs
    %Zencoder.Error{} = response ->
      # timed out? Zencoder broken? Computers are hard! Perhaps some nice retry logic.
      # Check out our integration reliability guide:
      # https://app.zencoder.com/docs/guides/advanced-integration/stable-integration
  end
  ```

## [Jobs](https://app.zencoder.com/docs/api/jobs)

Create a [new job](https://app.zencoder.com/docs/api/jobs/create).

  ````elixir
  # Basic job
  Zencoder.Job.create(%{input: "http://s3.amazonaws.com/zencodertesting/test.mov"})

  # More extensive job, see https://app.zencoder.com/docs/api/encoding for more encoding settings
  Zencoder.Job.create(%{
    input: "s3://zencodertesting/test.mov",
    outputs: [
      %{
        label: "mp4 high",
        url: "s3://your-bucket/output-file-name.mp4",
        h264_profile: "high"
      },
      %{
        url: "s3://your-bucket/output-file-name.webm",
        label: "webm",
        format: "webm"
      },
      %{
        url: "s3://your-bucket/output-file-name.ogg",
        label: "ogg",
        format: "ogg"
      },
      %{
        url: "s3://your-bucket/output-file-name-mobile.mp4",
        label: "mp4 low",
        size: "640x480"
      }
    ]
  })
  ````

Get [details](https://app.zencoder.com/docs/api/jobs/show) about a job.

  ````elixir
  Zencoder.Job.details(12345)
  ````

Get [progress](https://app.zencoder.com/docs/api/jobs/progress) on a job.

  ````elixir
  Zencoder.Job.progress(12345)
  ````

[List jobs](https://app.zencoder.com/docs/api/jobs/list). By default this returns the last 50 jobs, but this can be altered in an optional Map.

  ````elixir
  Zencoder.Job.list(%{page: 1, per_page: 5, state: "finished"})
  ````


[Cancel](https://app.zencoder.com/docs/api/jobs/cancel) a job

  ````elixir
  Zencoder.Job.cancel(12345)
  ````

[Resubmit](https://app.zencoder.com/docs/api/jobs/resubmit) a job

  ````elixir
  Zencoder.Job.resubmit(12345)
  ````

## [Inputs](https://app.zencoder.com/docs/api/inputs)

Get [details](https://app.zencoder.com/docs/api/inputs/show) about an input.

  ````elixir
  Zencoder.Input.details(12345)
  ````

Get [progress](https://app.zencoder.com/docs/api/inputs/progress) for an input.

  ````elixir
  Zencoder.Input.progress(12345)
  ````

## [Outputs](https://app.zencoder.com/docs/api/outputs)

Get [details](https://app.zencoder.com/docs/api/outputs/show) about an output.

  ````elixir
  Zencoder.Output.details(12345)
  ````

Get [progress](https://app.zencoder.com/docs/api/outputs/progress) for an output.

  ````elixir
  Zencoder.Output.progress(12345)
  ````

## [Reports](https://app.zencoder.com/docs/api/reports)

Reports are great for getting usage data for your account. All default to 30 days from yesterday with no [grouping](https://app.zencoder.com/docs/api/encoding/job/grouping), but this can be altered in the optional Map. These will return `422 Unprocessable Entity` if the date format is incorrect or the range is greater than 2 months. Correct date format is `YYYY-MM-DD`.

Get [all usage](https://app.zencoder.com/docs/api/reports/all) (Live + VOD).

  ````elixir
  Zencoder.Report.all

  # For a specific date range
  Zencoder.Report.all %{from: "2013-05-01", to: "2013-06-01"}

  # For a specific grouping
  Zencoder.Report.all %{grouping: "aperture-testing"}
  ````

Get [VOD usage](https://app.zencoder.com/docs/api/reports/vod).

  ````elixir
  Zencoder.Report.vod

  # For a specific date range
  Zencoder.Report.vod %{from: "2013-05-01", to: "2013-06-01"}

  # For a specific grouping
  Zencoder.Report.vod %{grouping: "aperture-testing"}
  ````

Get [Live usage](https://app.zencoder.com/docs/api/reports/live).

  ````elixir
  Zencoder.Report.live

  # For a specific date range
  Zencoder.Report.live %{from: "2013-05-01", to: "2013-06-01"}

  # For a specific grouping
  Zencoder.Report.live %{grouping: "aperture-testing"}
  ````

## [Accounts](https://app.zencoder.com/docs/api/accounts)

Create a [new account](https://app.zencoder.com/docs/api/accounts/create). A unique email address and terms of service are required, but you can also specify a password (and confirmation) along with whether or not you want to subscribe to the Zencoder newsletter. New accounts will be created under the Test (Free) plan.

  ````elixir
  Zencoder.Account.create %{email: "tedjones@example.com", terms_of_service: 1}

  # Create an account with all possible options
  Zencoder.Account.create %{
    email: "tedjones2@example.com",
    terms_of_service: 1,
    password: "sureamgladforssl",
    password_confirmation: "sureamgladforssl",
    newsletter: 0
  }
  ````

Get [details](https://app.zencoder.com/docs/api/accounts/show) about the current account.

  ````elixir
  Zencoder.Account.details
  ````

Turn [integration mode](https://app.zencoder.com/docs/api/accounts/integration) on (all jobs are test jobs).

  ````elixir
  Zencoder.Account.integration
  ````

Turn off integration mode, which means your account is live (and you'll be billed for jobs).

  ````elixir
  Zencoder.Account.live
  ````
----