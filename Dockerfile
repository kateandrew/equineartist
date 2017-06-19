FROM ruby:alpine
RUN apk --no-cache add git musl-dev nodejs imagemagick imagemagick-dev gcc make openssh && \
    mkdir /app
ADD . /app
WORKDIR /app
RUN bundle install
EXPOSE 4567
CMD middleman s