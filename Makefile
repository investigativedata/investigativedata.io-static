all: clean publish

publish: build site cloud sync

.PHONY: sync
sync:
	aws --profile nbg1 --endpoint-url https://s3.investigativedata.org --region eu-central-1 s3 sync build s3://investigativedata.io
	aws --profile nbg1 --endpoint-url https://s3.investigativedata.org --region eu-central-1 s3 sync site s3://investigativedata.io/aleph
	aws --profile nbg1 --endpoint-url https://s3.investigativedata.org --region eu-central-1 s3 sync cloud s3://investigativedata.io/cloud
	aws --profile nbg1 --endpoint-url https://s3.investigativedata.org --region eu-central-1 s3 sync hub s3://investigativedata.io/hub

build/index.html: build/assets
	cat index.html | sed -s s/style\.css/style\.min\.css/g > build/index.html

build/assets:
	mkdir -p build/assets

build/assets/style.min.css: build/assets
	node_modules/postcss-cli/index.js --no-map assets/style.css -u postcss-import -u postcss-url -u postcss-dropdupedvars -u autoprefixer -u cssnano -o build/assets/style.min.css

# build/pgp:
# 	cp -r pgp build/

build/%:
	cp $* build/

.PHONY: build
build: build/assets build/index.html build/qubes.txt build/assets/style.min.css build/assets/logo_animation.json

.PHONY: site
site:
	mkdocs build

.PHONY: clean
clean:
	rm -rf build
	rm -rf site
