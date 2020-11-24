FROM elixir:1.7.3

# Create non-root user
RUN adduser artus --disabled-password

# Install debian packages
RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools postgresql-client

# Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install --yes nodejs
RUN npm install -g yarn

# Switch to user
USER artus

# Install Phoenix packages
WORKDIR /home/artus
RUN mix local.hex --force
RUN mix local.rebar --force
RUN curl -o phoenix_new-1.2.5.ez https://raw.githubusercontent.com/phoenixframework/archives/master/phoenix_new-1.2.5.ez
RUN mix archive.install --force ./phoenix_new-1.2.5.ez

WORKDIR /app
EXPOSE 4000
