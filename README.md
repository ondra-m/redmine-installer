**This is a documentation for new unreleased version. For current version [go there](https://github.com/easyredmine/redmine-installer/tree/v1.0.7).**

# Redmine installer

Easy way hot to install/upgrade Redmine, EasyRedmine or EasyProject.

## Installation

Add this line to your application's Gemfile:

```
gem 'redmine-installer'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install redmine-installer
```

## Examples

### Help

To display global doucmentation for installer.

```
redmine help
```

You can also check more detailed documentation for each command.

```
redmine help [COMMAND]
```

### Common parameters and options


**PACKAGE:**
- Path to package. Can be absolute or relative path.
- You can also write specific version of Redmine (redmine package will be downloaded on that version). For example `redmine install v3.3.0`

**REDMINE_ROOT:**
- Path to directory where project will be or is installed.
- All files must be readable and writeable for current user.

**options:**
- _**--bundle-options OPTIONS**_ Options for bundle install. For example `--bundle-options "--without rmagick"`
- _**--silent**_ Less verbose installation.


### Installing

Create new project on empty directory. All argument are optional.

```
redmine help install
redmine install [PACKAGE] [REDMINE_ROOT] [options]
```

Allowed options:
- _**--bundle-options OPTIONS**_
- _**--silent**_

### Upgrading

Upgrade existing project with new package.

```
redmine help upgrade
redmine upgrade [PACKAGE] [REDMINE_ROOT] [options]
```

Allowed options:
- _**--bundle-options OPTIONS**_
- _**--silent**_
- _**--profile PROFILE\_ID**_ Use saved profile.
- _**--keep**_ Keep selected files or directories. Example `--keep git_directory`
