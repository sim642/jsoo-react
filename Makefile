project_name = jsoo-react

opam_file = $(project_name).opam
current_hash = $(shell git rev-parse HEAD)

.PHONY: build build-prod dev test test-promote deps fmt init publish-example

build:
	dune build @@default

build-prod:
	dune build --profile=prod @@default

dev:
	dune build -w @@default

test:
	dune build @runtest

test-promote:
	dune build @runtest --auto-promote

# Alias to update the opam file and install the needed deps
deps: $(opam_file)

fmt:
	dune build @fmt --auto-promote

publish-example:
	git checkout master && dune build --profile=prod @@default && cd example && yarn webpack:production \
	&& cd - && git checkout gh-pages && cp example/build/index.* . && git commit -am "$(current_hash)"
	
# Update the package dependencies when new deps are added to dune-project
$(opam_file): dune-project
	dune build @install        # Update the $(project_name).opam file
	opam install . --deps-only --with-test # Install the new dependencies

init:
  # Create a local opam switch
	opam switch create . 4.10.0 --deps-only --with-test && opam pin add gen_js_api https://github.com/jchavarri/gen_js_api.git#typ_var
