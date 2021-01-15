FROM ruby:2.7.2
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs yarn && apt-get clean
RUN gem install foreman

# This image is only intended to be able to run this app in a production RAILS_ENV
ENV RAILS_ENV production

ENV DATABASE_URL mysql2://root:root@mysql/collections_publisher_development
ENV GOVUK_APP_NAME collections-publisher
ENV PORT 3071

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* .ruby-version $APP_HOME/
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'
RUN bundle install --jobs 4

ADD package.json yarn.lock $APP_HOME/
RUN yarn install --frozen-lockfile

ADD . $APP_HOME

RUN GOVUK_WEBSITE_ROOT=https://www.gov.uk GOVUK_APP_DOMAIN=www.gov.uk bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD foreman run web
