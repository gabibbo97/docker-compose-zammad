ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}
# Download Zammad
ARG ZAMMAD_VERSION
WORKDIR /opt/zammad
RUN mkdir -p /opt/zammad \
  && curl -sSfL https://ftp.zammad.com/zammad-${ZAMMAD_VERSION}.tar.gz | tar -xzf -
# Install Zammad
RUN gem install bundler rake rails
RUN apt-get update -qq && apt-get install -y libimlib2 libimlib2-dev
RUN bundle install --without test development mysql
RUN apt-get update -qq && apt-get install -y nodejs npm && npm install --global yarn
# Set permissions
RUN useradd -c 'Zammad' -M -s /usr/sbin/nologin zammad
RUN chown -R zammad:zammad /opt/zammad
# Insecure OpenSSL
ARG INSECURE_OPENSSL='n'
RUN if [ "$INSECURE_OPENSSL" = "y" ]; then echo "Insecure OPENSSL!"; sed -ie 's/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/' /etc/ssl/openssl.cnf; fi
# Add entrypoint
RUN apt-get update -qq && apt-get install -y wait-for-it
COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
USER zammad:zammad
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]