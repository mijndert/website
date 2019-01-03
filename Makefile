.PHONY: build serve push clean

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s

push: clean build
	rsync -uav _site/ mijndert@mijndertstuij.nl:~/www/ --delete

clean:
	$(RM) -r _site/
