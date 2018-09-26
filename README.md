# Toggl::Jobcan

This gem provides `toggl-jobcan` command, which synchronises working time data in Toggl to JobCan.

This gem requires Ruby >= 2.5.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toggl-jobcan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toggl-jobcan

## Configuration

Prepare `~/.toggl` including Toggl API token so that [Toggl::Worktime](https://github.com/limitusus/toggl-worktime) works.

Prepare `~/.toggl_worktime` for [Toggl::Worktime](https://github.com/limitusus/toggl-worktime) (Path can be specified via `-c` option).

Prepare `~/.jobcan` YAML file that includes:

From v0.3.0 you need to specify *Jobcan ID*, not *Jobcan Attendance ID*. For details read the [documentation by Jobcan](https://jobcanwf.zendesk.com/hc/ja/articles/224910508).

```yaml
email: YOUR_EMAIL_ADDRESS
password: YOUR_PASSWORD
```

## Usage

Pass date strings in `%Y%m%d` format.

```console
toggl-jobcan 20170201 20170202
```

To synchronise all days in a month, utilise `seq` command:

```console
toggl-jobcan `seq -f '201702%02g' 1 28`
```

You can simulate the inputs with `--dryrun` option.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/limitusus/toggl-jobcan. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Toggl::Jobcan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/limitusus/toggl-jobcan/blob/master/CODE_OF_CONDUCT.md).
