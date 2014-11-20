# Redmine::Installer

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

Simple install and ugrade

```
$ wget http://www.redmine.org/releases/redmine-2.3.0.zip
$ wget http://www.redmine.org/releases/redmine-2.5.0.zip

$ redmine install redmine-2.3.0.zip
$ redmine upgrade redmine-2.5.0.zip
```

Set languages

```
$ redmine --locale cs install redmine-2.3.0.zip
```

Install from git

```
$ redmine install git@github.com:redmine/redmine.git --source git
$ redmine upgrade --source git
```

Install from git with specific branch

```
$ redmine install git@github.com:redmine/redmine.git --source git --branch 2.3-stable
$ redmine upgrade --source git
```

## Usage

```
redmine GLOBAL_FLAGS ACTION ARGUMENTS FLAGS
```

See help for more details

```
redmine help
```

#### Global flags

<table>
  <thead>
    <tr>
      <th>arguments</th>
      <th>default value</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>--verbose / -v</td>
      <td>false</td>
      <td>show verbosed output</td>
    </tr>
    <tr>
      <td>--locale / -l</td>
      <td>en</td>
      <td>language for application</td>
    </tr>
  </tbody>
</table>


#### Shortcut

Some commands have defined shortcut for quicker access. Fox example:

```
redmine install package
# is equal as
redmine i package
```

Commands shortcut.

```
i -> install
u -> upgrade
b -> backup
```

#### Common flags for all command

<table>
  <thead>
    <tr>
      <th>arguments</th>
      <th>default</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>--environment / --env / -e</td>
      <td>production</td>
      <td>
        environment for redmine<br>
        you can set more environment like: <br>
        &nbsp;&nbsp;&nbsp;<i>--env env1,env2,env3</i>
      </td>
    </tr>
  </tbody>
</table>

## Install

Install new redmine instance from archive or git.

#### Steps:

- **1. Redmine root** - insert _path_ where redmine will be installed
	- _path_ must point to the folder
	- target folder must be writable
- **2. Load package** - loading package to temporary folder
- **3. Database configuration** - you can choose type of DB which you want to use
	- currently: MySQL or PostgreSQL
	- you can also skip this step and run migration manually
- **4. Email sending configuration** - you can set email configuration
- **5. Install** - install commands are executed
- **6. Moving redmine** - redmine is moved from temporarily folder to given _redmine\_root_
- **7. Webserve configuration** - you can generate setting from selected webserver

#### From archive

Supported archives are **.zip** and **.tar.gz**.

```
redmine install PATH_TO_PACKAGE

# with environment
redmine install PATH_TO_PACKAGE --env environment
```

#### From git

```
redmine install GIT_REPO --source git

# with specific branch
redmine install GIT_REPO --source git --branch GIT_BRANCH --env environment
```

##### Arguments

<table>
  <thead>
    <tr>
      <th>argument</th>
      <th>default</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>--branch / -b</td>
      <td>master</td>
      <td>
        git branch
      </td>
    </tr>
  </tbody>
</table>


## Upgrade

Upgrading existing instance of redmine with archive or defined git repository. If your redmine contain plugins which are not part of new package - all these plugins will be kept otherwise are replaced with those from package.

Final step will ask you if you want save steps configuration. If you say _YES_, configuration will be stored as profile so next time you can upgrade redmine faster.

```
redmine upgrade PACKAGE --profile PROFILE_ID
```

Profiles are stored on *HOME_FOLDER/.redmine-installer-profiles.yml*.

#### Steps:

- **1. Redmine root** - where is redmine located
- **2. Load package** -  loading package to temporary folder
- **3. Validation** - validation of current redmine
- **4. Backup** - backup current instance
	- **full backup**: complete _redmine\_root_ with database
	- **backup** (default): only configuration file with database
	- **database**: only database
- **5. Upgrading** - upgrade commands are executed
- **6. Moving redmine** - current redmine is upgraded by new files
- **7. Profile saving** - generating profile (see profile section)


#### From archive

```
redmine upgrade PATH_TO_PACKAGE

# with environment
redmine upgrade PATH_TO_PACKAGE --env environment
```

#### From git

```
redmine upgrade --source git

# with environment
redmine upgrade --source git --env environment
```


## Backup

```
redmine backup
```

#### Steps:

- **1. Redmine root** - where is redmine located
- **2. Validation** - validation of current redmine
- **3. Backup** - backup current instance
	- **full backup**: complete _redmine\_root_ with database
	- **backup** (default): only configuration file with database
	- **database**: only database
- **4. Profile saving** - generating profile (see profile section)

You can choose one of 3 types.

<table>
  <thead>
    <tr>
      <th>Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Full backup</b></td>
      <td>archive full redmine_root folder with all you databases defined at config/database.yml</td>
    </tr>
    <tr>
      <td><b>Backup</b></td>
      <td>
        archive
        <ul>
          <li>files folder</li>
          <li>config/database.yml, config/configuration.yml</li>
          <li>databases</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><b>Only database</b></td>
      <td>archive only databases</td>
    </tr>
  </tbody>
</table>


 
