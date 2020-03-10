#!/bin/bash
#!/bin/bash
version=$(grep version Dockerfile|awk '{print $2}'|cut -d\" -f2)
release="pipetools"
if [ "$version" ]; then
  echo Version: "$version" found
  docker login
  docker tag "$release":"$version" marcinbojko/"$release":"$version"
  docker tag "$release":"$version" marcinbojko/"$release":latest
  docker push marcinbojko/"$release":"$version"
  docker push marcinbojko/"$release":latest
else
 echo Version tag is empty
 exit 1
fi
