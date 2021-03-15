# How to contribute

We love pull requests from everyone. By participating in this project,
you agree to abide by our [code of conduct](CODE_OF_CONDUCT.md).

We expect everyone to follow the code of conduct anywhere in this project's codebases,
issue trackers, chatrooms, and mailing lists.

1. Fork the repo.

1. Run `./bin/setup`.

1. Run the tests. We only take pull requests with passing tests, and it's great
   to know that you have a clean slate: `bundle exec rake`

1. Add a test for your change. Only refactoring and documentation changes
   require no new tests. If you are adding functionality or fixing a bug,
   we need a test!

1. Make the test pass.

1. Write a [good commit message][commit].

1. Push to your fork and submit a pull request.

Others will give constructive feedback.
This is a time for discussion and improvements,
and making the necessary changes will be required before we can
merge the contribution.

## Start Application in Development

Configure your local environment with `./bin/setup`.
After that start the application with `./bin/up`.

## Performance Improvements

Improving our users' experience should be the primary goal of any optimization.

If you contribute a performance improvement,
you must submit performance profiles
that show that your optimizations
make a significant impact
on our request times.

Request-level profiles are our best measure
of how users experience our app.
Many other performance measurements,
such as benchmarks,
can give inaccurate impressions
of an optimization's overall impact.

Tools like [Rack MiniProfiler] are helpful
for generating request-level performance profiles.

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability.

Additionally to [RuboCop], we use [Hound] for comments on code quality and style issues,
allowing us to better review and maintain a clean codebase.

## Security

For security inquiries or vulnerability reports, please email
<hello@eve-calendars.com>.

Thanks,
Devas Weddo

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[RuboCop]: https://www.rubocop.org
[Hound]: https://www.houndci.com
[Rack MiniProfiler]: https://github.com/MiniProfiler/rack-mini-profiler
