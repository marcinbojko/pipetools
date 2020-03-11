FROM alpine:3.11.3 AS build
LABEL version="v0.0.2"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --no-cache --update -t deps ca-certificates sudo curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip  && pip3 install --upgrade pip yamllint dos2unix \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh
CMD ["busybox"]
