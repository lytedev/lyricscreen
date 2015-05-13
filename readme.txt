LyricScreen
===========

A probably-overkill and powerful way of managing lyrics or verse
displays for concerts or church services.

**NOTE**: This project is under heavy development and is not recommended
for mission-critical functions.

Installation
------------

``pip``
~~~~~~~

You can get lyricscreen super easily through PyPI! You can check out the
`package page <https://pypi.python.org/pypi/lyricscreen>`__ or use
```pip`` <https://pip.pypa.io/en/stable/>`__ as follows:

.. code:: bash

    pip install lyricscreen

Git
~~~

-  Clone this repo
   (``git clone https://github.com/lytedev/lyricscreen``)
-  Run the install script (``make install``)

Windows Installer
~~~~~~~~~~~~~~~~~

**TODO**: Coming soon!

Basic Usage
-----------

Command Line
~~~~~~~~~~~~

If you installed lyricscreen through ``pip``, as long as your ``PATH``
is properly configured, you should be able to just run ``lyricscreen``
from your terminal. lyricscreen should automatically fire up and open a
browser page with access to the web console. It's that simple!

Windows Installation
~~~~~~~~~~~~~~~~~~~~

**TODO**: Windows installation usage

Development
-----------

-  ``npm`` **N**\ ode **P**\ ackage \*\*M\*anager (You'll need
   ``node.js`` installed)
-  ``gulp`` Streaming build system (``npm install -g gulp``)
-  ``bower`` Front-end package manager (``npm install -g bower``)

For web client development, your work is primarily done in the
``WebInterface`` directory. Run ``npm install`` to fetch the node
modules we use before running ``gulp`` to build our app.

You can also use ``gulp watch`` to continually build as changes are
made. If you use a LiveReload plugin, this also sends refresh messages
on file changes for a reload.

Concerns
--------

-  There is zero security currently implemented. Anyone could
   theoretically open up their browser and open a console through your
   http server and do whatever they want.
-  Currently absolutely zero ease-of-use and UX. Eventual goal is run
   the program and have everything pre configured and managable from one
   interface without needing to edit configs or restart stuff. See TODO
   list.

TODO
----

-  Authentication info/system for console connections?
-  Idea: on-run, prompt or generate an admin password, require initial
   auth from "console" connections. Should be fine enough for short
   term?
-  Better UX for default web admin client
-  More complex, optional song formatting options for fancier slides
   (background images? text-align? Google fonts?)
-  Playlist creation/saving/modification/loading/listing/viewing
-  Song creation/saving/modification/loading/listing/viewing
-  Always: prettier, better organized code (conform to Python code
   standards and have properly formatted docstrings... or docstrings *at
   all*)
-  YAML config files as an option?
-  Nice introduction page for users
