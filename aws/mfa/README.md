# set up MFA for cli on your computer

in order to increase security you should block any use of personal AWS keys with out MFA enabled

you will need to setup MFA on your computer and then get a temp credentials whenever you want to access AWS from cli.

 

## Automatic installtion:
let the script do it for you:
run this command: (it will do what is listed in the manual part)


download the `gen_set_MFA_credentials.sh`  file and run it

you will be asked to add these variables

`AWS_ID = XXXXXXXX`

`AWS_USERNAME  -  ${YOUR AWS USERNAME} `


## use mfa on cli:
once done you can run this command 


`aws_mfa <YOUR MFA TOKEN>`

this will do the following

add to your environment temporary credentiald that will enable you to work with aws (valid for 24 hours). (hence the source in the command)

create a file called MFA_credentials under ~/.aws directory, that will be read when you create a new session (hance the lines added to ~/.bash_profile or .zshrc)

once activated you will be able to access aws from cli (including terraform)
