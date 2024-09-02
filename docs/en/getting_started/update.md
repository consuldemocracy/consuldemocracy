# Keeping your fork updated

## Configuring your git remotes

If you created your fork correctly and cloned it locally, running:

```bash
git remote -v
```

it should output something alike:

> origin  git@github.com:your_user_name/consuldemocracy.git (fetch)\
> origin  git@github.com:your_user_name/consuldemocracy.git (push)

Now we have to add Consul Democracy's github as upstream remote with:

```bash
git remote add upstream git@github.com:consuldemocracy/consuldemocracy.git
```

and to check everything is fine with

```bash
git remote -v
```

again you should get:

> upstream  git@github.com:consuldemocracy/consuldemocracy.git (fetch)\
> upstream  git@github.com:consuldemocracy/consuldemocracy.git (push)\
> origin  git@github.com:your_user_name/consuldemocracy.git (fetch)\
> origin  git@github.com:your_user_name/consuldemocracy.git (push)

## Pulling changes from Consul Democracy

Start by creating a branch named **upstream** from your **master** branch to apply Consul Democracy changes:

```bash
git checkout master
git pull
git checkout -b upstream
```

Then we can fetch all changes from the **Consul Democracy** remote server with:

```bash
git fetch upstream
```

And then you can choose to either:

A. Get all the latest changes on Consul Democracy's **master** branch with `git merge upstream/master`.

B. Just update up to an specific release tag (so you can do incremental updates if you're more than one release behind). For example to update up to [v0.9](https://github.com/consuldemocracy/consuldemocracy/releases/tag/v0.9) release just: `git merge v0.9`.

## Merging changes

After the previous section `merge` command, there are three possible outcomes:

A. You get a nice `Already up-to-date.` response. That means your fork is up to date with Consul Democracy 😊👌.

B. You get a screen on your git configured editor showing the commit message `Merge remote-tracking branch 'upstream/master' into upstream`. That means git was able to grab latest changes from Consul Democracy's master branch, and it can merge them without code change conflicts. Finish the commit.

C. You get some git errors along with a `Automatic merge failed; fix conflicts and then commit the result.` message. That means there are conflicts between the code changes you did and the ones done on Consul Democracy repository since the last time you update it. That's the main reason we strongly recommend often updates of your fork (think at least monthly). Resolve merge conflicts carefully and commit them.

Now you can just simply push your **upstream** branch to github and create a Pull Request so you can easily check all changes going into your repo, and see your tests suite runs.

Remember you can always quickly check changes that will come from Consul Democracy to your fork by replacing **your_org_name** on the url: <https://github.com/your_org_name/consuldemocracy/compare/master...consuldemocracy:master>.
