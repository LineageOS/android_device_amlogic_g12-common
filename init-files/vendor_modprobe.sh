#! /vendor/bin/sh

# Default to /vendor/lib/modules
MODULES_PATH="/vendor/lib/modules/"

MODPROBE="/vendor/bin/modprobe"
MODULES=`${MODPROBE} -d ${MODULES_PATH} -l`

# Iterate over module list and modprobe them in background
for MODULE in ${MODULES}; do
	${MODPROBE} -a -b -d ${MODULES_PATH} ${MODULE} &
done

# Wait until all the modprobes are finished
wait
