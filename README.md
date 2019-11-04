# Git Gud

<img src="https://raw.githubusercontent.com/almightycouch/gitgud/master/apps/gitgud_web/assets/static/images/logo.svg?sanitize=true" align="right" width="240" height="240">

A Git source code management tool written in Elixir.

* [x] Git HTTP and SSH support.
* [x] User authentication and permissions.
* [x] Fully integrated GraphQL API.
* [x] Native (NIF) implementation of Git commands.
* [x] Customizable Git storage backend.
* [x] Issue tracker.
* [x] Code reviews.
* [ ] Continuous integration.

See the [Getting Started](http://almightycouch.com/gitgud/docs/getting-started.html) guide and the [online documentation](http://almightycouch.com/gitgud/docs).

## Install dependencies

First, ensure you have [libgit2](https://libgit2.github.com) installed on your system:

#### OSX
```bash
brew install libgit2
```

#### Ubuntu
```bash
sudo apt-get install libgit2-dev
```

You will also need [Node.js](https://nodejs.org/en/) to compile Web assets and [PostgreSQL](https://www.postgresql.org) to store your application data.

## Clone and compile

Clone the latest version of the project:

```bash
git clone https://github.com/almightycouch/gitgud.git
```

Download Hex dependencies and compile everything:

```bash
mix deps.get
mix compile
```

## Install Javascript dependencies

Install all NPM packages required by Webpack to generate Web assets:

```bash
npm install --prefix apps/gitgud_web/assets
```

## Generate SSH public keys

In order to provide SSH as a Git transport protocol, you must generate a valid SSH public key for the server:

```bash
ssh-keygen -m PEM -t rsa -f apps/gitgud/priv/ssh-keys/ssh_host_rsa_key
```

## Setup database

The last step before running the server is to create and initialise the SQL database:

```bash
mix ecto.setup
```

## Run server

Finally, start both HTTP (port 4000) and SSH (port 8989) endpoints:

```bash
mix phx.server
```
