FROM ruby:alpine
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' >> /etc/apk/repositories
RUN apk --no-cache add git musl-dev nodejs imagemagick=6.9.6.8-r1 imagemagick-dev=6.9.6.8-r1 gcc make openssh && \
    mkdir /app
ADD . /app
WORKDIR /app
RUN bundle install
EXPOSE 4567
CMD middleman s