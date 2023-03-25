.PHONY: build.prod
build.prod:
	npm install --prefix ./assets
	mix deps.get --only prod
	MIX_ENV=prod mix assets.deploy
	MIX_ENV=prod mix compile
	MIX_ENV=prod mix release --overwrite

.PHONY: develop
develop: deps.get
	iex -S mix phx.server

.PHONY: test
test: deps.get
	mix test

.PHONY: lint
lint: deps.get format
	mix compile --force --warnings-as-errors
	mix format --check-formatted
	
distclean:
	mix clean --all
	$(RM) -R node_modules
	$(RM) -R _build/

deps.get:
	npm install --prefix ./assets
	mix deps.get

format:
	mix format
