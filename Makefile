.DEFAULT_GOAL := help

BOM     := bin/appliance-bom
COMPOSE := docker compose --env-file .env.images --env-file .env

.PHONY: help
help:
	@echo "Philterd Appliance"
	@echo
	@echo "  make bootstrap   generate .env and a TLS certificate (run once)"
	@echo "                   CERT=/path/x.crt KEY=/path/x.key to use your own"
	@echo "  make images      regenerate .env.images from bom.yaml"
	@echo "  make build       build the components that are not published yet"
	@echo "  make up          start the core profile"
	@echo "  make up-full     start every profile, including Arbiter"
	@echo "  make down        stop the appliance, keeping data volumes"
	@echo "  make destroy     stop the appliance and delete its data volumes"
	@echo "  make logs        follow logs"
	@echo "  make bom         list the bill of materials"
	@echo "  make doctor      check that every component resolves"

.env:
	@echo "No .env found. Run 'make bootstrap' first." >&2
	@exit 1

.env.images: bom.yaml
	@$(BOM) render-env > $@
	@echo "Wrote $@ from bom.yaml"

# Pass CERT= and KEY= to use your own certificate instead of a generated one:
#   make bootstrap CERT=/etc/ssl/philterd.crt KEY=/etc/ssl/philterd.key
.PHONY: bootstrap
bootstrap:
	@bin/appliance-bootstrap $(if $(CERT),--cert $(CERT)) $(if $(KEY),--key $(KEY))

.PHONY: images
images:
	@rm -f .env.images
	@$(MAKE) --no-print-directory .env.images

.PHONY: build
build: .env.images
	@$(BOM) build

.PHONY: up
up: .env .env.images
	$(COMPOSE) up -d

.PHONY: up-full
up-full: .env .env.images
	$(COMPOSE) --profile full up -d

.PHONY: down
down: .env .env.images
	$(COMPOSE) --profile full down

.PHONY: destroy
destroy: .env .env.images
	$(COMPOSE) --profile full down -v

.PHONY: logs
logs: .env .env.images
	$(COMPOSE) --profile full logs -f

.PHONY: bom
bom:
	@$(BOM) list

.PHONY: doctor
doctor:
	@$(BOM) doctor
