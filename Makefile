build: 
	./setup.py sdist

install: build
	tar -C dist -xzf $(shell ls -t dist/lyricscreen*.tar.gz | head -1)
	python3 $(shell ls -td dist/lyricscreen*/ | head -1)setup.py install

publish:
	./setup.py register
	./setup.py sdist upload
	- pip uninstall lyricscreen
	pip install --no-cache-dir lyricscreen

cleanall: clean cleanbin

clean:
	- rm -rf lyricscreen.egg-info
	- rm -rf build
	- rm -rf dist

cleanbin:
	- rm -rf /usr/local/lib/python3.4/site-packages/lyricscreen*
	- rm -f /usr/local/bin/lyricscreen

