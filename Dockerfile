FROM alpine:3.16.2 AS build
LABEL version="v0.1.4"
LABEL release="pipetools"
LABEL maintainer="marcinbojko"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# additions

COPY --from=hashicorp/terraform:1.2.8 /bin/terraform /bin/terraform
COPY --from=aquasec/tfsec:v1.27.5 /usr/bin/tfsec /bin/tfsec
COPY --from=anchore/syft:v0.54.0 /syft /bin/syft
COPY --from=hadolint/hadolint:v2.10.0 /bin/hadolint /bin/hadolint
COPY --from=ghcr.io/terraform-linters/tflint:v0.39.3 /usr/local/bin/tflint /bin/tflint
COPY --from=datree/datree:1.6.6 /datree /bin/datree

# shellcheck disable=SC2169
RUN apk update && apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip py3-wheel tzdata git httpie sshfs shellcheck jq npm && pip3 install --no-cache-dir --upgrade wheel pip yamllint jsonlint dos2unix \
  && npm install -g dockerfilelint \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh \
  && apk upgrade
CMD ["busybox"]
