#~/bin/bash

set -e
set -u

data_dir=freesurfer-data/data

tar_excludes="--exclude=CVS --exclude=tiff --exclude=jpeg --exclude=expat
	--exclude=xml2 --exclude=glut --exclude=x86cpucaps"

# make working directory
curdir=$(pwd)
wdir=$(mktemp -d)

# process input
fs_snapshot="$1"
if [ -d "$fs_snapshot" ]; then
	echo "Copy/filter sources into $wdir"
	tar $tar_excludes -cf- "$fs_snapshot" | tar -xf- -C "$wdir"
	dname=$(basename $fs_snapshot)
else
	echo "Unpack sources into $wdir"
	tar $tar_excludes -xf "$curdir/$fs_snapshot"  -C "$wdir"
	dname=dev
fi

cd $wdir

# Assure that it is called dev for consistency
[ "$dname" = "dev" ] && dname="+dev" || { mv $dname dev; dname=""; }

echo "Determine version"
# Use STABLE_VER_NUM to deduce the base version
uversion_raw=$(sed -n -e '/STABLE_VER_NUM/s,.*="v\(.*\)",\1,gp' dev/distribution/build_release_type.csh)
LC_ALL=C lastmod=$(find dev -type f -exec ls -og --time-style=long-iso {} \; |sort --key 4 |tail -n1 | cut -d ' ' -f 4,4 | tr -d "-")

# That base version seems to be a base in dev as well but we want to
# add a 'dev' suffix if we are wrapping development branch instead of
# the stable one, and since +d > +c development should always be
# higher than the one in stable release
uversion="${uversion_raw}${dname}+cvs${lastmod}"

echo "Got version: ${uversion}"

echo "Repackaging"
mkdir -p $data_dir
# major hunk of data
mv dev/distribution $data_dir
# copy data files that are scattered around
for i in $(find dev -type f -regextype posix-egrep -regex '.*\.(img|gz|mgh|mgz)'); do
	mkdir -p ${data_dir}/$(dirname ${i#dev/*})
	mv $i ${data_dir}/${i#dev/*}
done
mv dev/talairach_avi/*mni_average_305* \
	freesurfer-data//data/talairach_avi
mv dev/talairach_avi/3T18yoSchwartzReactN32_as_orig* \
	freesurfer-data/data/talairach_avi

# strip unnecessary pieces
find dev/fsfast/docs/ -name '*.pdf' -delete
find dev/ -name 'callgrind*' -delete
find dev/ -name '*.bak' -delete
rm dev/INSTALL
rm dev/config/*
rm dev/qdec/qdec-boad-wink.wnk
rm dev/fsfast/docs/MGH-NMR-StdProc-Handbook.doc
# docs with no sources
rm -rf dev/docs
# generated wrappers
find dev -name '*Tcl.cxx' -delete
# generated Makefiles
find dev -iname Makefile | xargs grep -l 'generated by automake' | xargs rm -f
# CorTech not-even-non-free components
rm -rf dev/tk{medit,register2,surfer}
grep -il CorTech dev/scripts/* | xargs rm -f
# There are some filts under fsfast/bin/ which rely on tksurfer etc,
# but at least they are legal to distribute, so let's keep them


echo "Compute checksums"
# compute checksums for data and store them in the sources
find $data_dir -type f -exec md5sum {} \; > dev/freesurfer-data.md5sums
sed -i -e "s,$data_dir,.," dev/freesurfer-data.md5sums

# make nice upstream src dirs
mv freesurfer-data freesurfer-data-${uversion}
mv dev freesurfer-${uversion}

echo "Build orig tarballs"
tar -czf freesurfer_${uversion}.orig.tar.gz freesurfer-${uversion}
tar -czf freesurfer-data_${uversion}.orig.tar.gz freesurfer-data-${uversion}

echo "Move tarballs to final destination"
mv freesurfer*.orig.tar.gz $curdir

echo "Clean working directory"
rm -rf $wdir

echo "Done"

