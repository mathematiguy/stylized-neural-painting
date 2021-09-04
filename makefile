IMAGE_NAME := $(shell basename `git rev-parse --show-toplevel` | tr '[:upper:]' '[:lower:]')
GIT_TAG ?= $(shell git log --oneline | head -n1 | awk '{print $$1}')
DOCKER_REGISTRY := mathematiguy
IMAGE := $(DOCKER_REGISTRY)/$(IMAGE_NAME)
HAS_DOCKER ?= $(shell which docker)
RUN ?= $(if $(HAS_DOCKER), docker run $(DOCKER_ARGS) --gpus all --rm -v $$(pwd):/work -w /work -u $(UID):$(GID) $(IMAGE))
UID ?= $(shell id -u)
GID ?= $(shell id -g)
DOCKER_ARGS ?=

.PHONY: docker docker-push docker-pull enter enter-root

all: checkpoints_G_oilpaintbrush \
	checkpoints_G_rectangle \
	checkpoints_G_markerpen \
	checkpoints_G_watercolor \
	checkpoints_G_oilpaintbrush_light \
	checkpoints_G_rectangle_light \
	checkpoints_G_markerpen_light \
	checkpoints_G_watercolor_light

RENDERER ?= watercolor
IMG_PATH ?= ./test_images/trampoline-bear.png
demo_prog: checkpoints_G_$(RENDERER) $(IMG_PATH)
	$(RUN) python3 demo_prog.py --img_path $(IMG_PATH) --canvas_color 'white' --max_m_strokes 500 --max_divide 5 --renderer $(RENDERER) --renderer_checkpoint_dir checkpoints_G_$(RENDERER) --net_G zou-fusion-net --disable_preview

checkpoints_G_oilpaintbrush: checkpoints_G_oilpaintbrush.zip
	unzip -o $<

checkpoints_G_rectangle: checkpoints_G_rectangle.zip
	unzip -o $<

checkpoints_G_markerpen: checkpoints_G_markerpen.zip
	unzip -o $<

checkpoints_G_watercolor: checkpoints_G_watercolor.zip
	unzip -o $<

checkpoints_G_oilpaintbrush_light: checkpoints_G_oilpaintbrush_light.zip
	unzip -o $<

checkpoints_G_rectangle_light: checkpoints_G_rectangle_light.zip
	unzip -o $<

checkpoints_G_markerpen_light: checkpoints_G_markerpen_light.zip
	unzip -o $<

checkpoints_G_watercolor_light: checkpoints_G_watercolor_light.zip
	unzip -o $<

checkpoints_G_oilpaintbrush.zip:
	$(RUN) gdown --id "1sqWhgBKqaBJggl2A8sD1bLSq2_B1ScMG"

checkpoints_G_rectangle.zip:
	$(RUN) gdown --id "162ykmRX8TBGVRnJIof8NeqN7cuwwuzIF"

checkpoints_G_markerpen.zip:
	$(RUN) gdown --id "1XsjncjlSdQh2dbZ3X1qf1M8pDc8GLbNy"

checkpoints_G_watercolor.zip:
	$(RUN) gdown --id "19Yrj15v9kHvWzkK9o_GSZtvQaJPmcRYQ"

checkpoints_G_oilpaintbrush_light.zip:
	$(RUN) gdown --id "1kcXsx2nDF3b3ryYOwm3BjmfwET9lfFht"

checkpoints_G_rectangle_light.zip:
	$(RUN) gdown --id "1aHyc9ukObmCeaecs8o-a6p-SCjeKlvVZ"

checkpoints_G_markerpen_light.zip:
	$(RUN) gdown --id "1pP99btR2XV3GtDHFXd8klpdQRSc0prLx"

checkpoints_G_watercolor_light.zip:
	$(RUN) gdown --id "1FoclmDOL6d1UT12-aCDwYMcXQKSK6IWA"


clean:
	rm -rf checkpoints_G_*

JUPYTER_PASSWORD ?= jupyter
JUPYTER_PORT ?= 8888
.PHONY: jupyter
jupyter: IMAGE=mathematiguy/stylized-neural-painting-codeserver
jupyter: UID=root
jupyter: GID=root
jupyter: DOCKER_ARGS=-u $(UID):$(GID) --rm -it -p $(JUPYTER_PORT):$(JUPYTER_PORT) -e NB_USER=$$USER -e NB_UID=$(UID) -e NB_GID=$(GID)
jupyter:
	$(RUN) jupyter lab \
		--allow-root \
		--port $(JUPYTER_PORT) \
		--ip 0.0.0.0 \
		--NotebookApp.password=$(shell $(RUN) \
			python3 -c \
			"from IPython.lib import passwd; print(passwd('$(JUPYTER_PASSWORD)'))")

docker:
	docker build $(DOCKER_ARGS) --tag $(IMAGE):$(GIT_TAG) -f Dockerfile .
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest
	docker build $(DOCKER_ARGS) --tag $(IMAGE)-codeserver:$(GIT_TAG) -f codeserver.Dockerfile .
	docker tag $(IMAGE)-codeserver:$(GIT_TAG) $(IMAGE)-codeserver:latest

docker-push:
	docker push $(IMAGE):$(GIT_TAG)
	docker push $(IMAGE):latest
	docker push $(IMAGE)-codeserver:$(GIT_TAG)
	docker push $(IMAGE)-codeserver:latest

docker-pull:
	docker pull $(IMAGE):$(GIT_TAG)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest
	docker pull $(IMAGE)-codeserver:$(GIT_TAG)
	docker tag $(IMAGE)-codeserver:$(GIT_TAG) $(IMAGE):latest

enter: DOCKER_ARGS=-it
enter:
	$(RUN) bash

enter-root: DOCKER_ARGS=-it
enter-root: UID=root
enter-root: GID=root
enter-root:
	$(RUN) bash
