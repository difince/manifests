#!/bin/bash

dir_name=sboms-workbenches
rm -rf $dir_name
mkdir $dir_name

#exec < docs/image_lists/kf_latest_automl_images.txt
#exec < docs/image_lists/kf_latest_manifests_images.txt
#exec < docs/image_lists/kf_latest_pipelines_images.txt
#exec < docs/image_lists/kf_latest_serving_images.txt
#exec < docs/image_lists/kf_latest_training_images.txt
exec < docs/image_lists/kf_latest_workbenches_images.txt


FAILED_IMAGES=()

while read line
do
	image=$line
	echo "Generating SBOM for image: $image"

	image_name=$(echo $image | cut -d ":" -f 1 | cut -d "/" -f 3)
	image_repo=$(echo $image | cut -d ":" -f 1 | cut -d "/" -f 2)
	image_tag=$(echo $image | cut -d ":" -f 2)
	filename="${image_repo}_${image_name}_${image_tag}.json"

	if [[ $image != *:* ]]; then
		image_name=$(echo $image | cut -d "/" -f 3)
		image_repo=$(echo $image | cut -d "/" -f 2)
		filename="${image_repo}_${image_name}_latest.json"
	fi

	# syft
	cyclonedx_format_filename="./$dir_name/cyclonedx_$filename"
	syft --scope all-layers $image -o cyclonedx-json=${cyclonedx_format_filename} -q

	if [ $? -eq 0 ]; then
		echo "SBOM generation SUCCESS"
	else
		echo "SBOM generation FAILED: $image"
		FAILED_IMAGES+=$image
	fi
done

echo "Failed Images:"
echo "${FAILED_IMAGES[@]}"

