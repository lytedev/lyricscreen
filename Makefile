build:
	./setup.py sdist

usedist: build
	mkdir -p build
	rm -rf build/lyricscreen-latest
	tar -C build -xzf dist/lyricscreen*.tar.gz
	mv build/lyricscreen* build/lyricscreen-latest
	./build/lyricscreen-latest/setup.py install

dist: cleanosx
	./setup.py sdist upload
	- pip uninstall lyricscreen
	echo "Waiting 5 seconds before reinstalling via pip..."
	sleep 5
	pip install --no-cache-dir lyricscreen

clean:
	rm -rf build
	rm -rf dist

cleanosx:
	rm -rf /usr/local/lib/python3.4/site-packages/lyricscreen*
	rm -f /usr/local/bin/lyricscreen

