# Customizing tests

Tests check whether the application behaves as expected. For this reason, it is **extremely important** that you write tests for all the features you introduce or modify. Without tests, you'll have no reliable way to confirm that the application keeps working as expected whenever you change the code or upgrade to a new version of Consul Democracy. Consul Democracy contains more than 6000 tests checking the way the application behaves; without them, it'd be impossible to make sure that new code doesn't break any existing behavior.

Since running the tests on your development machine might take more than an hour, we recommend [configuring your fork](../getting_started/configuration.md) so it uses a continuous integration system that runs all the tests whenever you make changes to the code. When changing the code, we recommend running the tests in a development branch by opening pull requests (a.k.a. merge requests) so the tests run before the custom changes are added to the `master` branch.

Then, if some tests fail, check one of the tests and see whether the test fails because the custom code contains a bug or because the test checks a behavior that no longer applies due to your custom changes (for example, you might modify the code so only verified users can add comments, but there might be a test checking that any user can add comments, which is the default behavior). If the test fails due to a bug in the custom code, fix it ;). If it fails due to a behavior that no longer applies, then you'll have to change the test.

Changing a test is a two-step process:

1. Make sure the test checking the default behavior in Consul Democracy isn't run anymore
2. Write a new test for the new behavior

For the first step, add a `:consul` tag to the test or block of tests. For example, let's check this code:

```ruby
describe Users::PublicActivityComponent, controller: UsersController do
  describe "follows tab" do
    context "public interests is checked" do
      it "is displayed for everyone" do
        # (...)
      end

      it "is not displayed when the user isn't following any followables", :consul do
        # (...)
      end

      it "is the active tab when the follows filters is selected", :consul do
        # (...)
      end
    end

    context "public interests is not checked", :consul do
      it "is displayed for its owner" do
        # (...)
      end

      it "is not displayed for anonymous users" do
        # (...)
      end

      it "is not displayed for other users" do
        # (...)
      end

      it "is not displayed for administrators" do
        # (...)
      end
    end
  end
end
```

In the first context, only the first test will be executed. The other two tests will be ignored because they contain the `:consul` tag.

The second context contains the `:consul` tag itself, so none of its tests will be executed.

Remember: whenever you add a `:consul` tag to a test because the application no longer behaves as that test expects, write a new test checking the new behavior. If you don't, the chances of people getting 500 errors (or, even worse, errors that nobody notices) when visiting your page will dramatically increase.

To add a custom test, use the custom folders inside the `spec/` folder:

* `spec/components/custom/`
* `spec/controllers/custom/`
* `spec/models/custom/`
* `spec/routing/custom/`
* `spec/system/custom/`
