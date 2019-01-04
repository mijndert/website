.PHONY: build serve push invalidate clean

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s

push: clean build
	aws s3 sync --delete _site/ s3://mijndertstuij.nl/

invalidate:
	aws cloudfront create-invalidation --distribution-id E2UZTDTT76WG3V --paths "/*"

clean:
	$(RM) -r _site/
