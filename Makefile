.PHONY: test-run

test-build:
	-kubectl create ns test--build--${service}
	kubectl apply -n test--build--${service} -f build-secrets
	argo -n test--build--${service} submit -f build/${service}/build_params_example.yaml --log build/${service}/build.argo.yaml 

test-build-nofollow:
	-kubectl create ns test--build--${service}
	kubectl apply -n test--build--${service} -f build-secrets
	argo -n test--build--${service} submit -f build/${service}/build_params_example.yaml build/${service}/build.argo.yaml

delete-test-build:
	-kubectl delete ns test--build--${service}

test-build-all:
	make test-build-nofollow service=version-store-backend
	make test-build-nofollow service=version-store-frontend
	
delete-test-build-all:
	make delete-test-build service=version-store-backend
	make delete-test-build service=version-store-frontend

test-run:
	python test-run.py
	-kubectl create ns test--run--version-store
	kubectl apply -n test--run--version-store -f test-run