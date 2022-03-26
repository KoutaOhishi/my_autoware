#! /bin/bash
cd ~/my_autoware/docker/

xhost +local:$USER

docker run -it \
	--device /dev/:/dev/ \
	--mount type=bind,src=$(pwd)/src/,dst=/home/user/catkin_ws/src/,bind-propagation=shared \
	-e LOCAL_UID=$(id -u $USER) \
	-e LOCAL_GID=$(id -g $USER) \
	-e DISPLAY=$DISPLAY \
	-e QT_X11_NO_MITSHM=1 \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	-e  CONTAINER_NAME="autoware" \
	--shm-size=512m \
	--name autoware \
	--privileged \
	--user user \
	koutaohishi/autoware \
	/bin/bash 
