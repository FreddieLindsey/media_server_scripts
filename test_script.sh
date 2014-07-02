# Send the disc_mount as the input variable to get the name and year out. $1 defines the request, $2 is the disc mounting point or the search term
get_disc_info () {
	case $1 in
	"volume_name") 
		output=$(diskutil info $2 | grep 'Volume Name: ')
		output=$(echo $output | sed 's/\(Volume Name: \)//')
		volume_name=$output
	;;
	"disc_kind")
		output=$(drutil status | grep 'Type: ' | grep 'Name: ')
		output=$(echo $output | sed 's/\(Type: \)//')
		output=$(echo $output | sed 's/\(Name: \).*//')
		disc_kind=$output
	;;
	"title") $get_movie_info 
	;;
	"year")
	;;
	*) echo "There is a fault with the script, please re-write" >&2
	;;
	esac
}

get_disc_info "disc_kind"
echo "$disc_kind" >&2