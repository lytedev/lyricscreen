
build:
	./setup.py sdist
	mkdir -p build
	rm -rf build/lyricscreen-latest
	tar -C build -xzf dist/lyricscreen*.tar.gz
	mv build/lyricscreen* build/lyricscreen-latest
	./build/lyricscreen-latest/setup.py install

clean:
	rm -rf build
	rm -rf dist
