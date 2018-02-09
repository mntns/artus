<p align="center">
  <img width="444" height="205" src="https://raw.githubusercontent.com/EddyShure/artus/master/logo/IAS_Logo_rendered.png">
</p>

---

[![Inline docs](http://inch-ci.org/github/EddyShure/artus.svg)](http://inch-ci.org/github/EddyShure/artus)

> Phoenix application used to run the [bibliographical database](https://bias.internationalarthuriansociety.com) of the [International Arthurian Society](http://internationalarthuriansociety.com/)

## Building

Building the application for development is straightforward:
```shell
https://github.com/EddyShure/artus
cd artus/
mix do deps.get, compile
```

Setup the database:
```
mix ecto.setup
```

Install JS dependencies:
```
yarn install
```

## Deployment
TODO

## Maintainers
* [Eddy Shure](https://github.com/EddyShure)
