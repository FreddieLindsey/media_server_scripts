Finds largest file

echo "/""$(find /Users/Freddie/Downloads/Incomplete/James\ Bond\ Die\ Another\ Day\ \(2002\)avchd\ 1080p\(EN\ NL\)\ B-Sam -type f -ls | grep "$(find /Users/Freddie/Downloads/Incomplete/James\ Bond\ Die\ Another\ Day\ \(2002\)avchd\ 1080p\(EN\ NL\)\ B-Sam -type f -ls | awk -F $' ' '{print $7}' | sort -n | tail -n 1)" | cut -d '/' -f 2-)"