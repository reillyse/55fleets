FROM ruby:2.5.5


RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN apt-get update && apt-get -y upgrade
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y postgresql-client  --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y rsyslog --no-install-recommends
RUN apt-get update && apt-get install -y yui-compressor --no-install-recommends  && rm -rf /var/lib/apt/lists/*
RUN echo "*.*          @logs3.papertrailapp.com:16615" >> /etc/rsyslog.conf


EXPOSE 3000

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install
COPY . /usr/src/app
#FROM bishbashbox/base-rails

CMD service rsyslog restart  &&  bundle exec rake assets:precompile && bundle exec unicorn -p 3000 -E production -c ./config/unicorn.rb
