#!/bin/bash

releasever="$(lsb_release -rs)"
mirrorsite="free.nchc.org.tw"

for file in \
  /etc/yum.repos.d/fedora{,-updates,-updates-testing}.repo
do
  printf "update: %-48s" "$(basename ${file} ".repo")"

  if [ ! -f "${file}" ]; then
    printf "[\e[1;33mskip\e[0m]\n"
  else
    sed -i -e 's|download.fedoraproject.org/pub|'"${mirrorsite}"'|g' \
      ${file} && printf "[\e[1;32mdone\e[0m]\n" || printf "[\e[1;31mfail\e[0m]\n"
  fi
done


for file in \
  /etc/yum.repos.d/rpmfusion-{,non}free{,-rawhide,-updates,-updates-testing}.repo
do
  printf "update: %-48s" "$(basename ${file} ".repo")"

  if [ ! -f "${file}" ]; then
    printf "[\e[1;33mskip\e[0m]\n"
  else
    sed -i -e 's|^#baseurl=|baseurl=|g' \
           -e 's|^mirrorlist=|#mirrorlist=|g' \
           -e 's|download1.rpmfusion.org|'"${mirrorsite}"'/rpmfusion|g' \
      ${file} && printf "[\e[1;32mdone\e[0m]\n" || printf "[\e[1;31mfail\e[0m]\n"

    if echo "${file}" | egrep -q "free.repo$"; then
      printf "update: %-48s" "$(basename ${file} ".repo") (extra)"

      if [ "${releasever}" != "23" ]; then
        printf "[\e[1;33mskip\e[0m]\n"
      else
        sed -i -e 's|fedora/releases|fedora/development|g' \
               -e 's|Everything/||g' \
          ${file} && printf "[\e[1;32mdone\e[0m]\n" || printf "[\e[1;31mfail\e[0m]\n"
      fi
    fi
  fi
done
