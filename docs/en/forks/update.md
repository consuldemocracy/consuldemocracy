# Keeping your fork updated

## Configuring your git remotes

If you created your fork correctly and cloned it locally, running:
```bash
git remote -v
```

it should output something alike:

> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

Now we have to add consul github as upstream remote with:

```bash
git remote add upstream git@github.com:consul/consul.git
```

and to check everything is fine with

```bash
git remote -v
```

again you should get:

> upstream  git@github.com:consul/consul.git (fetch)<br/>
> upstream  git@github.com:consul/consul.git (push)<br/>
> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

## Pulling changes from consul

Start by creating a branch named **upstream** from your **master** branch to apply consul changes:

```bash
git checkout master
git pull
git checkout -b upstream
```

Then we fetch changes from **consul** remote server and it's master branch on to our feature branch:

```bash
git fetch upstream
git merge upstream/master
```

Now there are three possible outcomes:

A. You get a nice `Already up-to-date.` response. That means your fork is up to date with consul 😊👌

B. You get a screen on your git configured editor showing the commit message `Merge remote-tracking branch 'upstream/master' into upstream`. That means git was able to grab latest changes from consul's master branch, and it can merge them without code change conflicts. Finish the commit.

C. You get some git errors along with a `Automatic merge failed; fix conflicts and then commit the result.` message. That means there are conflicts between the code changes you did and the ones done on consul repository since the last time you update it. That's the main reason we strongly recommend often updates of your fork (think at least monthly). Resolve merge conflicts carefully and commit them.

Now you can just simply push your **upstream** branch to github and create a Pull Request so you can easily check all changes going into your repo, and see your tests suite runs.

Remember you can always quickly check changes that will come from consul to your fork by replacing **your_org_name** on the url: https://github.com/your_org_name/consul/compare/master...consul:master
