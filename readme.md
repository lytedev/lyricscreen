# LyricScreen

A probably-overkill and powerful way of managing lyrics or verse displays for
concerts or church services.

![Glamour shot][glamour_shot]

**NOTE**: This project is under heavy development and is not recommended for
mission-critical functions. There isn't even a changelog at this point since
stuff is changing all the time, ok?!

## Installation

### pip

You can get LyricScreen easily through PyPI! You can check out the [package
page][lyricscreen_pypi] or use [pip][pip] as follows:

```bash
pip install lyricscreen
```

**NOTE**: Windows Users: When you run `lyricscreen` for the first time, it
will try to symlink the `web_client` which will fail unless you run it in an
elevated command prompt or as Administrator. So, when you run it for the first
time (per user), you will need to do so from a command prompt running as
Administrator.

### Git

To build from source:

* Clone this repo (`git clone https://github.com/lytedev/lyricscreen`)
* Move into the directory (`cd lyricscreen`)
* Run the install script
  * `make install` for the *nix folks (I hope)
  * Windows users will have to run the following command (you'll need the
    proper PATH setup to run Python from your command prompt!) `python
    setup.py bdist_msi` and then run the newly built
    `dist/lyricscreen-X.X.X.win32.msi` to install the program.

**NOTE**: Windows Users: When you run `lyricscreen` for the first time, it
will try to symlink the `web_client` which will fail unless you run it in an
elevated command prompt or as Administrator. So, when you run it for the first
time (per user), you will need to do so from a command prompt running as
Administrator.

### Windows Installer

**TODO**: Coming soon! I need to implement building this via wine on Linux
and make it happen on PyPi updates. For now, refer to installation via Git
instructions on how to build a Windows installer.

## Basic Usage

### Command Line

If you installed LyricScreen through `pip`, as long as your `PATH` is properly
configured, you should be able to just run `lyricscreen` from your terminal.
LyricScreen should automatically fire up and open a browser page with access
to the web console. It's that simple!

`lyricscreen --help` will show all the command line flags and options.

### Windows Installation

**TODO**: Windows installation usage. For now, you'll have to have Python
scripts and such setup in your PATH and follow the Command line usage.

## Configuration

Generate the default config with `lyricscreen --create-config`. It will tell
you the location of the generated default config file. Open the file in your
favorite text editor and modify the values to suit your needs.

The command line binary accepts an argument pointing to your preferred config
file if you require multiple configurations and switch between them
frequently.

## Development

### Backend

The module is contained in the `lyricscreen` directory.

### Web Client

The web client is found in the `lyricscreen/http` directory, but you'll need to
do a bit of setup to contribute properly. It runs on
`lyricscreen/httpserver.py`, though it's capable of running through other HTTP
servers such as Apache or nginx, since the web client is really just some html
files, stylesheets, and some fairly straightforward JavaScript.

To get setup for contributing to the Web Client, you'll need the following
packages installed.

* `npm` **N**ode **P**ackage **M**anager (You'll need `node.js` installed)
* `gulp` Streaming build system (`npm install -g gulp`)
* `bower` Front-end package manager (`npm install -g bower`)

Once that's done, navigate to the web client directory (`lyricscreen/http`) and
do the following to build the assets.

```bash
npm install
bower install
gulp
```

You can also use `gulp watch` to continually build as changes are made. If you
use a LiveReload plugin, this also sends refresh messages on file changes for
a reload.

It's highly recommended to symlink the development directory's web client to the
directory LyricScreen uses by default by running this:

```
ln -s "$PWD/lyricscreen/http" "$HOME/.config/lyricscreen/web_client"
```

## Concerns

* There is zero security currently implemented. Anyone could theoretically open
  up their browser and open a console through your http server and do whatever
  they want.
* Currently absolutely zero ease-of-use and UX. Eventual goal is run the program
  and have everything pre configured and managable from one interface without
  needing to edit configs or restart stuff. See TODO list.

## TODO

* Authentication info/system for console connections?
  * Idea: on-run, prompt or generate an admin password, require initial auth from
    "console" connections. Should be fine enough for short term?
* Better UX for default web admin client
* More complex, optional song formatting options for fancier slides (background
  images? text-align? Google fonts?)
* Playlist creation/saving/modification/loading/listing/viewing
* Song creation/saving/modification/loading/listing/viewing
* Always: prettier, better organized code (conform to Python code standards and
  have properly formatted docstrings... or docstrings *at all*)
* YAML config files as an option?
* Nice introduction page for users on web client


[lyricscreen_pypi]: https://pypi.python.org/pypi/lyricscreen
[pip]: https://pip.pypa.io/en/stable/
[glamour_shot]: https://raw.githubusercontent.com/lytedev/lyricscreen/dev/docs/screenshots/Laptop-Mobile-screenshot-render.png

