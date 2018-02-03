# What
Tests that fail randomly are called "flakies", this one seems to be one:

**Randomized seed:** FILL_WITH_RANDOM_SEED

**Failure:**

```
  FILL_WITH_FAILURE_REPORT
```

# How
- [ ] Explain why the test is flaky, or under which conditions/scenario it fails randomly
- [ ] Explain why your PR fixes it

## Tips for flaky hunting

### Random values issues
If the problem comes from randomly generated values, running multiple times a single spec could help you reproduce the failure by running at your command line:
```bash
for run in {1..10}
do
  bin/rspec ./spec/features/budgets/investments_spec.rb:256
done
```

You can also try running a single spec in Travis:
Add option `:focus` to the spec and push your branch to Github, for example:
```ruby
scenario 'Show', :focus do
```

But remember to remove that `:focus` changes afterwards when submitting your PR changes!

### Test order issues
Running specs in the order they failed may discover that the problem is that a previous test sets an state in the test environment that makes our flaky fail/pass. Tests should be independent from the rest.

After executing rspec you can see the seed used, add it as an option to rspec, for example:
`bin/rspec --seed 55638` (check **Randomized seed** value at beginning of issue)

### Other things to watch for
- Time related issues (current time, two time or date comparisons with miliseconds/time when its not needed)
- https://semaphoreci.com/community/tutorials/how-to-deal-with-and-eliminate-flaky-tests
