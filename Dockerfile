FROM ruby:2.6.5
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs yarn && apt-get clean
RUN gem install foreman

ENV DATABASE_URL mysql2://root:root@mysql/collections_publisher_development
ENV GOVUK_APP_NAME collections-publisher
ENV PORT 3071
ENV RAILS_ENV development
ENV REDIS_HOST redis

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* .ruby-version $APP_HOME/
RUN bundle install
ADD . $APP_HOME

COPY package.json ./
COPY yarn.lock ./
RUN yarn install
RUN cp yarn.lock /tmp

RUN GOVUK_WEBSITE_ROOT=https://www.gov.uk GOVUK_APP_DOMAIN=www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD foreman run web
