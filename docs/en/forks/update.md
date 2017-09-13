# Keeping your fork updated

## Configuring your git remotes

If you created your fork correctly and cloned it locally, running:
```bash
git remote -v
```

it should output something alike:

> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

Now we have to add consul github remote with:

```bash
git add remote consul git@github.com:consul/consul.git
```

and to check everything is fine with

```bash
git remote -v
```

again you should get:

> consul  git@github.com:consul/consul.git (fetch)<br/>
> consul  git@github.com:consul/consul.git (push)<br/>
> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

## Pulling changes from consul

We start by creating a branch **consul_pull** from **master** branch to apply consul changes:

```bash
git checkout master
git checkout -b consul_pull
```

Then we fetch changes from **consul** remote server and it's master branch on to our feature branch:

```bash
git fetch consul
git merge consul/master
```

Now there are three possible outcomes:

A. You get a nice `Already up-to-date.` response. That means your fork is up to date with consul 😊👌

B. You get a screen on your git configured editor showing the commit message `Merge remote-tracking branch 'consul/master' into consul_pull`. That means git was able to grab latest changes from consul's master branch, and it can merge them without code change conflicts. Finish the commit.

C. You get some git errors along with a `Automatic merge failed; fix conflicts and then commit the result.` message. That means there are conflicts between the code changes you did and the ones done on consul repository since the last time you update it. That's the main reason we strongly recommend often updates of your fork (think at least monthly). Resolve merge conflicts carefully and commit them.

Now you can just simply push **consul_pull** branch to github and create a Pull Request so you can easily check all changes going into your repo, and see your tests suite runs.

Remember you can always quickly check changes that will come from consul to your fork by replacing **your_org_name** on the url: https://github.com/your_org_name/consul/compare/master...consul:master
