FROM ubuntu:trusty
MAINTAINER Chris Gallimore "http://sonian.net"

RUN apt-get -qq update
RUN apt-get install -y wget
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
RUN wget -q http://packages.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add erlang_solutions.asc
RUN echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
RUN echo "deb     http://binaries.erlang-solutions.com/debian trusty contrib" > /etc/apt/sources.list.d/erlang_solutions_repo.list
RUN apt-get update
RUN RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y sensu git-core supervisor

RUN echo "EMBEDDED_RUBY=true" > /etc/default/sensu & ln -s /opt/sensu/embedded/bin/ruby /usr/bin/ruby
RUN /opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri

RUN RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server

RUN RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y esl-erlang

RUN wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.4.1/rabbitmq-server_3.4.1-1_all.deb && dpkg -i rabbitmq-server_3.4.1-1_all.deb
RUN mkdir /etc/rabbitmq/ssl
ADD ./files/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

RUN wget -q http://dl.bintray.com/palourde/uchiwa/uchiwa_0.3.2-1_amd64.deb && dpkg -i uchiwa_0.3.2-1_amd64.deb
ADD ./files/uchiwa.json /etc/sensu/

COPY ./files/supervisord.conf /etc/supervisord.conf

EXPOSE 22 3000 4567 5671 15672
CMD ["/usr/bin/supervisord"]
