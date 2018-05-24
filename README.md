<p align="center">
  <img width="444" height="205" src="https://raw.githubusercontent.com/EddyShure/artus/master/logo/IAS_Logo_rendered.png">
</p>

---

[![Inline docs](http://inch-ci.org/github/EddyShure/artus.svg)](http://inch-ci.org/github/EddyShure/artus)

> Phoenix application used to run the [bibliographical database](https://bias.internationalarthuriansociety.com) of the [International Arthurian Society](http://internationalarthuriansociety.com/)

## Building

To build the application in development:
```shell
https://github.com/EddyShure/artus
cd artus/
mix do deps.get, compile
```

Make sure, your PostgreSQL instance is running and setup the database:
```
mix ecto.setup
```

Install JS dependencies:
```
yarn install
```

## Installation on production server

The following steps should provide a brief outline to installing the application on a production server from scratch. You should already have some knowledge about systems administration, PostgreSQL and nginx.


1. Have a properly configured production machine. DNS, iptables and so on.
2. Install PostgreSQL, configure it, create an empty database (i.e. `artus_prod`) or load a SQL dump. Also, install the latest Erlang runtime.
3. Install the latest Erlang runtime.
4. Setup a nginx installation that is configured to reverse-proxy to `localhost:8888`. Make sure it handles SSL connections and use [Let's Encrypt](https://letsencrypt.org/).
5. Get a [SendGrid](https://sendgrid.com/) API key.
6. Deploy the application from your development machine (see below).
7. Put your SendGrid API key and PostgreSQL credentials into a `config/prod.secret.exs`. See [this guide](https://hexdocs.pm/phoenix/deployment.html) for more information.
8. Create a systemd service for the application. You can use `rel/artus.service` as an example.

## Deployment from development machine

Deployment is straightforward. Contact [Eddy Shure](https://github.com/EddyShure) for the SSH key and then simply run:

```sh
./rel/deploy.sh
```

If there are any migrations to run, execute this command:
```sh
bin/artus command Elixir.Release.Tasks migrate
```

## Maintainers
* [Eddy Shure](https://github.com/EddyShure)
