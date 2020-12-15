FROM node:lts AS builder

COPY /client/package.json /client/package-lock.json /client/
WORKDIR /client
RUN npm install

COPY /client /client/
RUN npm run build



FROM rocker/r-ver:4.0.3

RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev

RUN R -e "install.packages('plumber')"
RUN R -e 'install.packages("data.table")'
RUN R -e 'install.packages("seriation")'

COPY --from=builder /client/public /app/client/public
COPY /server /app/server
COPY runApp.R /app
WORKDIR /app

EXPOSE 8000

ENTRYPOINT ["Rscript", "runApp.R"]