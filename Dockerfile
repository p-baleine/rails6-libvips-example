FROM ruby:2.7

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  curl \
  apt-transport-https

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn

# libvips
RUN cd /tmp \
  && curl -LO https://github.com/libvips/libvips/releases/download/v8.9.2/vips-8.9.2.tar.gz \
  && tar zxvf vips-8.9.2.tar.gz \
  && cd vips-8.9.2 \
  && ./configure \
  && make \
  && make install \
  && ldconfig

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
