
# add this to the bash_profile 
for setup_script in .aliases .yaron_profile
do
  if [ -f ~/${setup_script} ]; then
          . ~/${setup_script}
  fi
done
