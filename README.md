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

#### Shortcut

```
i -> install
u -> upgrade
b -> backup
```

### Instalation

You can instal redmine package. Currently is supported only zip format.

```
redmine install Downloads/redmine-2.3.0.zip
```

Steps:
- *1. Redmine root* - where should be new redmine located
- *2. Load package* - extract package
- *3. Database configuration* - you can choose type of DB which you want to use
- *4. Email sending configuration* - email sending configuration
- *5. Install* - install commands are executed
- *6. Moving redmine* - redmine is moved from temporarily folder to given redmine_root
- *7. Webserve configuration* - generating webserver configuration

### Upgrade

```
redmine upgrade Downloads/redmine-2.5.2.zip
```

Final step will ask you if you want save step configuration. If you say YES, configuration will be stored as profile so next time you can upgrade redmine faster.

```
redmine upgrade Downloads/redmine-2.5.2.zip --profile 1
```

### Backup

```
redmine backup
```

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
