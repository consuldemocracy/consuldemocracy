# Contributing

We appreciate you want to help us by contributing to [Consul](https://github.com/consul/consul)'s Documentation. Here's a guide we made describing how to contribute changes to the project.

## Code of conduct

The core team members and the project's community adopts an inclusive Code of Conduct that you can read in the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.

## Reporting an issue and communications

The prefered way to report any missing piece of information is [opening an issue in the project's Github repo](https://github.com/consul/docs/issues/new). For more informal communication, contact us through [consul's gitter](https://gitter.im/consul/consul)

Before doing it, **please take some time to check the [existing issues](https://github.com/consul/docs/issues) and make sure what you are about to report isn't already reported** by another person. In case someone else reported the same problem before or a similar one, and you have more details about it, you can write a comment in the issue page... a little more help can make a huge difference!

In order to write a new issue, take into account these few tips to make it easy to read and comprehend:

- Try to use a descriptive and to-the-point title.
- It's a good idea to include some sections -in case they're needed- such as: steps to reproduce the bug, expected behaviour/response, actual response or screenshots.
- Also it could be helpful to provide your operating system, browser version and installed plugins.

## Resolving an issue

[Issues in Consul Docs](https://github.com/consul/docs/issues) labeled with `PRs-welcome` are well defined tasks ready to be documented by whoever wants to do it. In the other hand, the `not-ready` label marks tasks not well defined yet or subject to an internal decision, so we recommend not to try to resolve them until the core maintainers come to a resolution.

We suggest to follow these steps to keep a good track of the changes you're about to make:

- First of all, add a comment to any existing issue that your changes will address and resolve/close. If the issue has already someone assigned it means that person may be solving it, ask nicely about it.
- If there is no issue open about the changes you're going to make, sometimes makes sense to open it to start a little debate about it with other contributors and maintainers before the real work starts. Sometimes it prevents that debate from happening on the Pull Request comments, when it may be too late to revert some parts of the work done.
- [Fork the project](https://help.github.com/articles/fork-a-repo/) using your github account.
- Create a feature branch based on the `master` branch. To make it easier to identify, you can name it with the issue number followed by a concise and descriptive name (e.g. `123-fix_proposals_link`).
- Work in your branch committing there your changes.
- Once you've finished, send a **pull request** to the [Consul Docs repository](https://github.com/consul/docs/) describing your solution to help us understand it. It's also important to tell what issue you're addressing, so specify it in the pull request description's first line (e.g. `Fixes #123`).
- Core maintainers will review your PR and suggest changes if necessary. If everything looks good, your changes will be merged :)

> **Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github).

## How to contribute from your computer

### Gitbooks

This documentation is hosted online at [Gitbook](https://www.gitbook.com) for free, and its composed by [Markdown](https://es.wikipedia.org/wiki/Markdown) text files. Markdown its a lightweight markup language to give style to paragraphs, lists, etc... Check [Gitbook's Markdown syntax guide](https://toolchain.gitbook.com/syntax/markdown.html)

To visualize on your browser how your changes would look you can use [https://github.com/GitbookIO/gitbook](https://github.com/GitbookIO/gitbook) to start a localhost server that will render the documentation.

### Markdown Linter

To maintain Markdown syntax consistency we use [Markdown Linter](https://github.com/markdownlint/markdownlint) and a `.mdlrc` file that holds its configuration on the project's root directory.

To check your changes have no linting issues you first have to install the tool with `gem install mdl` and then execute it with `mdl .`

## Other ways of contributing

We'll appreciate any kind of contribution to Consul Docs. Even if you can't contribute to it writing new docs, you still can:

- Create issues to notify the project owners with as much information as you can provide about anything wrong/missing you see, and someone will take care of it as soon as possible.
- Help translate existing documentation into a language that you master well enough.

Gracias! ❤️❤️❤️
