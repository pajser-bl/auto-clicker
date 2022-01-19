#!/bin/sh
###################################################################################
# HELP                                                                            #
################################################################################### 
function help()
{
	# Display help
	echo "Usage: auto-clicker [OPTION]"
	echo "Try 'auto-clicker --help' for more information."
}
function bad_args()
{
	echo $1
	echo "Usage: auto-clicker [OPTION]"
	echo "Try 'auto-clicker --help' for more information."
	exit 1
}

function check_option_has_argument(){
	if [ ! $2 ]
	then
		bad_args "auto-clicker: argument $1 requiers device number"
	fi
}
		
###################################################################################
# DEFINE ARGS                                                                     #
###################################################################################
function parse_args()
{
	# DEFAULT ARGS
	device=15
	key_code=50
	no_key=0
	interval=0
	silent=0

	# ARGS REDEFINTION
	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]
	do
		case $1 in
			# HELP
			-h | --help)
				help
				exit 0
				;;
			# FLAGS
			-s | --silent)
				silent=1
				shift
				;;
			-n | --no-key)
				no_key=1
				shift
				;;
			# OPTIONS
			-d | --device)
				check_option_has_argument $1 $2
				device=$2
				shift # past value
				shift # past argument
				;;
			
			-k | --key)
				check_option_has_argument $1 $2
				key_code=$2
				shift # past argument
				shift # past value
				;;
			-i | --interval)
				check_option_has_argument $1 $2
				interval=$2
				shift # past argument
				shift # past value
				;;
			-t | --test)
				check_option_has_argument $1 $2
				device=$2
				xinput test $device
				exit 0
				;;
			-* | --*)
				bad_args "auto-clicker: unknown argument $1"
				exit 1
				;;
			*)
				POSITIONAL_ARGS+=("$1")
				shift # move to next argument
				;;
		esac
	done
	set -- "{POSITIONAL_ARGS[@]}"
}
###################################################################################
# PRINT CONTROL KEY                                                               #
###################################################################################
function control_key()
{
	if [ $no_key -ne 0 ]
	then
		echo "No auto-click key set, script will not stop clicking."
	else
		case $key_code in
			23)key_name='Tab';;
			36)key_name='Enter';;
			37)key_name='LeftCtrl';;
			50)key_name="LeftShift";;
			62)key_name="RightShift";;
			64)key_name="LeftAlt";;
			66)key_name="CapsLock";;
			*)key_name="unknown[$key_name]";;
		esac
		echo "Hold $key_name to auto-click, might be false :("		
	fi
}
###################################################################################
# INFORM                                                                          #
###################################################################################
function inform()
{
	if [ $silent -eq 0 ]
	then
		echo "Autoclicker started."
		echo "Wait interval between clicks set to $interval seconds."
		control_key
		echo "To exit press CONTROL+C"
	fi
}
###################################################################################
# CHECK KEY PRESSED                                                               #
###################################################################################
function check_key_pressed()
{
	[ ! -z $(xinput --query-state $device | grep -o "key\[$key_code\]=down") ]
}
###################################################################################
# CLICK LOOP WITH SLEEP                                                           #
###################################################################################
function click_loop_with_interval()
{
	while true
	do
		check_key_pressed && {sleep $interval; xdotool click 1}
	done
}
###################################################################################
# CLICK LOOP                                                                      #
###################################################################################
function click_loop()
{
	while true
	do
		check_key_pressed && xdotool click 1
	done
}
###################################################################################
# MAIN                                                                            #
###################################################################################
function main()
{
	parse_args "$@"
	inform
	click_loop
}
###################################################################################
main "$@"
