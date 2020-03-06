#
# Traefik
#

.PHONY: traefik-network
traefik-network:
	@docker network ls | grep -w traefik_dirty-laundry &>/dev/null || docker network create traefik_dirty-laundry &>/dev/null

.PHONY: traefik
traefik: traefik-network
	@docker inspect -f {{.State.Running}} traefik_dirty-laundry &>/dev/null || docker run \
		--restart unless-stopped \
		--name traefik_dirty-laundry \
		--network traefik_dirty-laundry \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--publish 80:80 \
		--expose 80 \
		--expose 8080 \
		--health-cmd 'nc -z localhost 80' \
		--health-interval 5s \
		--label traefik.enable=true \
		--label 'traefik.http.routers.api.rule=Host(`traefik.localhost`)' \
		--label traefik.http.routers.api.service=api@internal \
		--detach \
		traefik:2.1 \
			--entrypoints.web.address=:80 \
			--api \
			--accesslog \
			--providers.docker=true \
			--providers.docker.network=traefik_dirty-laundry \
			--providers.docker.exposedbydefault=false

.PHONY: traefik-cleanup
traefik-cleanup:
	@docker stop traefik_dirty-laundry &>/dev/null
	@docker rm traefik_dirty-laundry &>/dev/null
	@-docker network rm traefik_dirty-laundry &>/dev/null

.PHONY: traefik-restart
traefik-restart: traefik-cleanup traefik
traefik-restart: ## restart traefik
