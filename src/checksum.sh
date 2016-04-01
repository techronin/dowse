#!/usr/bin/env zsh

R=${$(pwd)%/*}
[[ -r $R/src ]] || {
    print "error: config.sh must be run from the src"
    return 1
}

zkv=1
source $R/zlibs/zuper
vars=(tmp)
maps=(execmap execrules execsums)
source $R/zlibs/zuper.init

zkv.load $R/build/execmap.zkv
zkv.load $R/build/execrules.zkv

act "generating execution rules"

builduid=`id -u`
buildgid=`id -g`
# generate configuration for sup
cat <<EOF > $R/src/sup/config.h

#define ENFORCE 1

#define HASH 1

#ifndef FLAGSONLY

#define USER $builduid
#define GROUP $buildgid

#define SETUID 0
#define SETGID 0

#define CHROOT ""
#define CHRDIR ""

static struct rule_t rules[] = {
EOF

notice "Computing checksums to lock superuser privileges for user `id -un`"

execsums=()

for x in ${(k)execmap}; do
    [[ "$execrules[$x]" = "root" ]] && {
        if [[ -r $R/build/$x ]]; then
            cksum=`sha256sum $R/build/$x`
        elif [[ -r ${execmap[$x]} ]]; then
            cksum=`sha256sum ${execmap[$x]}`
        else
            warning "$x: binary not found in build or path (${execmap[$x]})"
            continue
        fi
        cksum=${cksum[(w)1]}
        [[ "$cksum" = "" ]] && {
            warning "missing checksum for: $x"
            continue }
        execsums+=($x $cksum)
        act "$cksum $x"
        cat <<EOF >> $R/src/sup/config.h
{ USER, GROUP, "$x", "*", "$cksum" },
EOF
    }
done
zkv.save execsums $R/build/execsums.zkv

cat <<EOF >> $R/src/sup/config.h
{ 0 },
};
#endif
EOF

notice "Dowse build complete on `hostname` (`date`)"