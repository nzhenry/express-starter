ci: remove-containers build-image startup-app run-tests remove-unused-images stop-containers

cd: ci deploy

remove-containers:
	@docker rm express-starter-test || true
	@docker rm express-starter-tmp || true
	@docker rm express-starter-selenium-server || true
build-image:
	@docker build -t express-starter .
startup-app:
	@docker run -d	--name express-starter-tmp express-starter
run-tests:
	@docker run -d --name express-starter-selenium-server --link express-starter-tmp selenium/standalone-firefox
	@docker run -dit --name express-starter-test --link express-starter-selenium-server express-starter bash
	@docker exec express-starter-test npm test || true
	@docker exec express-starter-test bash -c 'cat test_reports/*.xml' > test_report.xml
remove-unused-images:
	@docker rmi $$(docker images -q) || true
stop-containers:
	@docker stop express-starter-test || true
	@docker exec express-starter-tmp bash -c 'kill $$(pidof gulp)' || true
	@docker stop express-starter-selenium-server || true
deploy:
	@docker stop express-starter || true
	@docker rm express-starter || true
	@docker run -d --name express-starter -e VIRTUAL_HOST=express-starter.livehen.com -e VIRTUAL_PORT=3000 express-starter
