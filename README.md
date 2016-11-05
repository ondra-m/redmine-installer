**This is a documentation for new unreleased version. For current version [go there](https://github.com/easyredmine/redmine-installer/tree/v1.0.7).**

# Redmine installer

Easy way hot to install/upgrade Redmine, EasyRedmine or EasyProject.

Please do not run installer on background. It may happen that process will be paused by some event. For example database may require enter password during backuping database.

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

To display global documentation for installer.

```
redmine help
```

You can also check more detailed documentation for each command.

```
redmine help [COMMAND]
```

### Installing

Create new project on empty directory. All argument are optional. Directory must be an empty or current user must have privileges to create it.

```
redmine help install
redmine install [PACKAGE] [REDMINE_ROOT] [options]
```

```
--bundle-options OPTIONS   Options for bundle install
--silent                   Less verbose installation
```

Examples:

Install Redmine. Installer will ask for every required parameters.
- `redmine install`

Install Redmine from redmine.zip package into /srv/redmine folder.
- `redmine install redmine.zip /srv/redmine`

Install Redmine without rmgaick dependencies.  
- `redmine install redmine.zip /srv/redmine --bundle-options "--without rmagick"`

### Upgrading

Upgrade existing project with new package. Full and correct upgrading is ensured by these steps:
1. project is build on temporary directory
2. previous root is deleted
3. projects is moved to target location

Since current root is deleted you should use option `--keep` if you want preserved some files.


```
redmine help upgrade
redmine upgrade [PACKAGE] [REDMINE_ROOT] [options]
```

```
--bundle-options OPTIONS   Options for bundle install
--silent                   Less verbose upgrading
--profile PROFILE_ID       Using saved profile
--keep PATH(s)             Keep selected files or directories
```

Examples:

Upgrade Redmine located on /srv/redmine with package redmine2.zip
- `redmine upgrade redmine2.zip /srv/redmine`

Upgrade Redmine and keep directory.
- `redmine upgrade redmine2.zip /srv/redmine --keep directory_i_want_keep`

Once you've saved profile you can use previouse "answer" again.
- `redmine upgrade redmine2.zip /srv/redmine --profile 1`

### Backuping

Backup existing project. You can backup full redmine with database or just database.

```
redmine help backup
redmine backup [REDMINE_ROOT]
```

Examples:

Backup project located on /srv/redmine
- `redmine upgrade /srv/redmine`
