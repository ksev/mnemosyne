#!/usr/bin/nu

def main [image: string, target_drive: string] {
	# Generate ignition file from out butane file
	let public_key = (cat ~/.ssh/home.pub)
	let ign_file = $"($image).ign"
	let base_iso = "iso/fedora-coreos-base.iso"

	if ($base_iso | path exists) != true {
			mkdir iso/
			let file_name = coreos-installer download -f iso --decompress	
			mv $file_name $base_iso
	}
	
	jsonnet $"($image).bu.jsonnet" --tla-str $"public_key=($public_key)" | 
		butane --pretty --strict --output $ign_file

	ignition-validate $ign_file

	try {
		rm $"iso/($image).iso" 
	}

	(
		coreos-installer iso customize 
			--dest-ignition $ign_file 
			--dest-device $target_drive
			-o $"iso/($image).iso" 
			$base_iso
	)

	rm $ign_file
}

