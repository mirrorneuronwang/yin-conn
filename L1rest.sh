#!/bin/bash

# change these paths (should be the only paths you need to change)
basedir=`pwd` # currently the GitHub repo
MAINDATADIR=${basedir}/data # base directory for your input data
MAINOUTPUTDIR=${basedir}/fsl # base directory for your ouput results


task=$1
run=$2
subj=$3
H=$4

datadir=${MAINDATADIR}/${subj}/MNINonLinear/Results/rfMRI_${task}_${run}
OUTPUTDIR=${MAINOUTPUTDIR}/${subj}/MNINonLinear/Results/rfMRI_${task}_${run}
mkdir -p $OUTPUTDIR

OUTPUT=${OUTPUTDIR}/L1_${task}_${run}_${H}-hemi
if [ -d ${OUTPUT}.feat ]; then
	rm -rf ${OUTPUT}.feat
	echo "deleting existing output"
fi

DATA=${datadir}/rfMRI_${task}_${run}_hp2000_clean.nii.gz
NVOLUMES=`fslnvols ${DATA}`

maskdir=${basedir}/masks/${subj}
N=0
for roi in V1 OFA FFA ATL pSTS IFG AMG OFC PCC; do
	let N=$N+1
	TSFILE=${OUTPUTDIR}/${H}_${roi}.txt
	fslmeants -i ${DATA} -o $TSFILE -m ${maskdir}/${H}_${roi}.nii
	eval INPUT$N=$TSFILE
done

#find and replace: run feat for smoothing
ITEMPLATE=${basedir}/templates/L1_rest.fsf
OTEMPLATE=${OUTPUTDIR}/L1_rest_${run}_${H}-hemi.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@INPUT1@'$INPUT1'@g' \
-e 's@INPUT2@'$INPUT2'@g' \
-e 's@INPUT3@'$INPUT3'@g' \
-e 's@INPUT4@'$INPUT4'@g' \
-e 's@INPUT5@'$INPUT5'@g' \
-e 's@INPUT6@'$INPUT6'@g' \
-e 's@INPUT7@'$INPUT7'@g' \
-e 's@INPUT8@'$INPUT8'@g' \
-e 's@INPUT9@'$INPUT9'@g' \
<$ITEMPLATE> ${OTEMPLATE}
feat ${OTEMPLATE}

# fix registration
rm -rf ${OUTPUT}.feat/reg
mkdir -p ${OUTPUT}.feat/reg
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
ln -s $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

# delete files that aren't necessary
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
