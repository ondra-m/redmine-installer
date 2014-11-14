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

## Usage

```
redmine GLOBAL_ARGUMENTS ACTION ARGUMENTS
```

#### Global arguments

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
      <td>languages for application</td>
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

#### Common arguments

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
        environment for redmine
      </td>
    </tr>
  </tbody>
</table>

### Instalation

You can instal redmine package from archive or git.

#### Steps:

- *1. Redmine root* - where should be new redmine located
- *2. Load package* - extract package
- *3. Database configuration* - you can choose type of DB which you want to use
- *4. Email sending configuration* - email sending configuration
- *5. Install* - install commands are executed
- *6. Moving redmine* - redmine is moved from temporarily folder to given redmine_root
- *7. Webserve configuration* - generating webserver configuration

#### From archive

Supported archives are **.zip** and **.tar.gz**.

```
# minimal
redmine install PATH_TO_PACKAGE

# full
redmine install PATH_TO_PACKAGE --env ENV1,ENV2,ENV3
```

#### From git

```
# minimal
redmine install GIT_REPO --source git

# full
redmine install GIT_REPO --source git --branch GIT_BRANCH --env ENV1,ENV2,ENV3
```

##### Arguments

<table>
  <thead>
    <tr>
      <th>argumnest</th>
      <th>default</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>--branch / -b</td>
      <td>master</td>
      <td>
        branch of git defined by GIT_REPO
      </td>
    </tr>
  </tbody>
</table>


### Upgrade

You can upgrade current redmine by archive or currently defined git repository. If your redmine contain plugins which are not part of new package - all these plugins will be kept otherwise are replaced with those from package.

Final step will ask you if you want save steps configuration. If you say YES, configuration will be stored as profile so next time you can upgrade redmine faster.

```
redmine upgrade PACKAGE --profile PROFILE_ID
```

Profiles are stored on *HOME_FOLDER/.redmine-installer-profiles.yml*.

#### Steps:

- *1. Redmine root* - where should be new redmine located
- *2. Load package* - extract package
- *3. Validation* - current redmine should be valid
- *4. Backup* - backup current redmine (see backup section)
- *5. Upgrading* - install commands are executed
- *6. Moving redmine* - redmine is moved from temporarily folder to given redmine_root
- *7. Profile saving* - generating profile (see profile section)


#### From archive

```
# minimal
redmine upgrade PATH_TO_PACKAGE

# full
redmine upgrade PATH_TO_PACKAGE --env ENV1,ENV2,ENV3
```

#### From git

```
# minimal
redmine upgrade --source git

# full
redmine upgrade --source git --env ENV1,ENV2,ENV3
```


### Backup

```
redmine backup
```

#### Steps:

- *1. Redmine root* - where should be new redmine located
- *2. Validation* - current redmine should be valid
- *3. Backup* - backup current redmine (see backup section)
- *4. Profile saving* - generating profile (see profile section)

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
 