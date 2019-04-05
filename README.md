# mw-bocker

Some bash scripts to get a super-lean [mediawiki](https://www.mediawiki.org/) installed and running via [PHP's built-in web server](https://www.php.net/manual/en/features.commandline.webserver.php).

Why?  The available [Vagrant](https://github.com/wikimedia/mediawiki-vagrant) and [Docker](https://github.com/wikimedia/mediawiki-docker) images for mediawiki are full-featured, but bloated and slow.  This set of scripts is designed to get you up and running with a [desired version of mediawiki](https://releases.wikimedia.org/mediawiki/) with a lean, opinionated configuration for quick testing.

## Prerequisites

```
bash
php5.4+ (preferably 7+)
some other, standard cli stuff
```

## Installing

1. ```git clone https://github.com/sbassett29/mw-bocker.git```

## Usage

1. First, configure ```env.sh``` to your liking and source it.
2. Then, run ```build.sh``` to install and configure mediawiki.
3. Finally, use the ```start.sh``` and ```stop.sh``` scripts to start and stop PHP's built-in web server.

## TODO

1. Support for commmon/deployed skins and extensions.
2. Support for quick pulls of gerrit patchsets.
3. Support for services (eh, maybe not).
4. Support for TLS, though this isn't too bad to set up via a Docker LAMP and PHP's internal web server does not support this.

## Authors

* **Scott Bassett** - [sbassett29](https://github.com/sbassett29)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
