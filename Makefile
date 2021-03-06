.PHONY: builder builder.build builder.create builder.start

PROJECT 	?= test
VOLUMES 	?= $(shell pwd)/examples
BUILDS 		?= ${VOLUMES}/builds
BUILDER 	?= ${PROJECT}-builder
MEMBER  	?= ${PROJECT}-mongooseim
MEMBER_BASE ?= ${PROJECT}-mongooseim
MEMBER_TGZ  ?= mongooseim-esl-34097d5-2015-11-09_135646.tar.gz

#
# Public
#

builder: builder.build builder.create builder.start

builder.destroy:
	-docker stop ${BUILDER}
	-docker rm ${BUILDER}

# TODO: unfinished!
#cluster-2:
#    make ${MEMBER}-1
#    make ${MEMBER}-2

#cluster-2.destroy:
#    make member.destroy MEMBER=${MEMBER}-1
#    make member.destroy MEMBER=${MEMBER}-2

#
# Private
#

builder.build:
	docker build -f Dockerfile.builder -t ${BUILDER} .

builder.create:
	docker create --name ${BUILDER} -h ${BUILDER} \
		-v ${VOLUMES}/builds:/builds ${BUILDER}

builder.start:
	docker start ${BUILDER}

builder.shell:
	docker exec -it ${BUILDER} bash

# MEMBER here is like test-mongooseim, i.e. no numeric suffix
member.build:
	docker build -f Dockerfile.member -t ${MEMBER} .

# TODO: temporary
# MEMBER here is like test-mongooseim-1, test-mongooseim-2, ...
member.create:
	-mkdir -p ${VOLUMES}/${MEMBER}
	-rm -rf ${VOLUMES}/${MEMBER}/mongooseim/Mnesia*
	cp ${BUILDS}/${MEMBER_TGZ} ${VOLUMES}/${MEMBER}/mongooseim.tar.gz
	docker create --name ${MEMBER} -h ${MEMBER} -P -t \
		-v ${VOLUMES}/${MEMBER}:/member ${MEMBER_BASE}
	./generate-hosts ${PROJECT} > ${VOLUMES}/${MEMBER}/hosts
	docker start ${MEMBER}

# TODO: unfinished!
# MEMBER here is like test-mongooseim-1, test-mongooseim-2, ...
#member.create:
#    docker create --name ${MEMBER} -h ${MEMBER} \
#        -v ${VOLUMES}/${MEMBER}:/member \
#        ${MEMBER_BASE}

# MEMBER here is like test-mongooseim-1, test-mongooseim-2, ...
member.start:
	docker start ${MEMBER}

# MEMBER here is like test-mongooseim-1, test-mongooseim-2, ...
member.destroy:
	-docker stop ${MEMBER}
	-docker rm ${MEMBER}
