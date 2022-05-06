#!/bin/bash
export DOCKER_BUILDKIT=1
release=$(grep -i "LABEL RELEASE" Dockerfile|awk '{print $2}'|cut -d\" -f2)
version=$(grep -i "LABEL VERSION" Dockerfile|awk '{print $2}'|cut -d\" -f2)
maintainer=$(grep -i "LABEL MAINTAINER" Dockerfile|awk '{print $2}'|cut -d\" -f2)
coverage="./coverage.txt"
echo Version: "$version" found
echo Release: "$release" found
echo maintainer: "$maintainer" found

if dockerfilelint Dockerfile; then
  echo "Dockerfilelint passed"
else
  echo "Dockerfilelint errors, correct"
  exit 1
fi

if [ -n "$version" ] && [ -n "$release" ]; then
  docker build --pull --no-cache --squash -t "$release":"$version" .
  build_status=$?
  docker container prune --force
  # let's tag latest
  docker tag "$release":"$version" "$release":latest
else
  echo "No version or release found, exiting"
  exit 1
fi
# coverage
if [ "$build_status" == 0 ]; then
  echo "Docker build succeed"
  rm -rf dive.log||true
  rm -rf ./*.txt||true
  date > "$coverage"
  {
    terraform version
    tfsec --version
    syft --version
    hadolint --version
    tflint --version
  } >> "$coverage"
  echo Trivy
  trivy image --output coverage-"$version"_trivy.txt "$release":"$version"
  echo Dive
  dive --ci "$release":"$version" > coverage-"$version"_dive.txt
  sed -i 's/\x1B\[[0-9;]*[JKmsu]//g' coverage-"$version"_dive.txt||true
  echo Dockle
  sudo dockle -f json -o coverage-"$version"_dockle.txt "$release":"$version"
else
 echo "Docker build failed, exiting now"
fi
