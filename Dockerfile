FROM ct2034/vnc-ros-kinetic-full:latest
RUN apt-get -y update
RUN apt-get install -y git
ENV SOURCE_PATH=$HOME/astrobee
RUN git clone https://github.com/nasa/astrobee.git $SOURCE_PATH
RUN cd $SOURCE_PATH && git submodule update --init --depth 1 description/media
ENV ANDROID_PATH="${SOURCE_PATH}_android"
RUN git clone https://github.com/nasa/astrobee_android.git $ANDROID_PATH

RUN cd $SOURCE_PATH && git checkout c8f3da73c5a4b3cff09f1b9095647f0dab795372
RUN cd $ANDROID_PATH && git checkout 5b07e4d626781a6f7e0a9cdf4397375cbe509803

RUN apt-get install -y wget
RUN $SOURCE_PATH/scripts/setup/add_ros_repository.sh
RUN apt-get -y update
RUN cd $SOURCE_PATH/scripts/setup/debians/ && ./build_install_debians.sh
RUN rm -rf /etc/apt/sources.list.d/arc-theme.list
RUN $SOURCE_PATH/scripts/setup/install_desktop_16_04_packages.sh
RUN rm /etc/ros/rosdep/sources.list.d/20-default.list
RUN rosdep init && rosdep update
ENV BUILD_PATH=$HOME/astrobee_build/native
ENV INSTALL_PATH=$HOME/astrobee_install/native
RUN $SOURCE_PATH/scripts/configure.sh -l -F -D
RUN apt-get install -y libignition-math2-dev
RUN cd $BUILD_PATH && make -j2
RUN echo "source $BUILD_PATH/devel/setup.bash && roslaunch astrobee sim.launch dds:=false robot:=sim_pub rviz:=true" >> /root/launch.sh && chmod +x /root/launch.sh

RUN apt-get -y install adb
