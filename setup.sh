#!/bin/bash

# Checks, updates and installs RVM, Gems, Ruby, JAVA, Bundler, Brew, npm, grunt, ant, xcode and  maven 

   # Set some colors
   Red='\033[0;31m';
   Gre='\033[0;32m';
   Yel='\033[1;33m';
   Blue='\033[0;34m';
   Orange='\033[0;33m';
   NoC='\033[0m';

check_rvm(){
	if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
                 printf "Sourcing already installed rvm to your environment\n"
 		 source "$HOME/.rvm/scripts/rvm"

	elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
                printf "Sourcing already installed rvm to your environment\n"
  		source "/usr/local/rvm/scripts/rvm"
	else
 		 printf "${Red}ERROR: An RVM installation was not found.\n${NoC}" 
		 printf "${Red}************ Now Installing RVM FOR YOU! ********************\n${NoC}"
                 rvm_stable	 
	fi
}

rvm_stable(){
	\curl -sSL https://get.rvm.io | bash -s stable
	rvm install ruby
	check_rvm
}

update_rvm_ruby(){
	rvm get head
	rvm autolibs homebrew
	rvm install ruby
}

check_ruby(){
	  rvm list > $TMPDIR/local_ruby_versions.txt
	  acceptable_ruby_version='1.9'
	  preferred_ruby_version='2.2'
  if grep -q $acceptable_ruby_version $TMPDIR/local_ruby_versions.txt
   then
      printf "Acceptable RVM Ruby version $acceptable_ruby_version confirmed as present on this machine\n"
      rm -f $TMPDIR/local_ruby_versions.txt
  
  elif grep -q $preferred_ruby_version $TMPDIR/local_ruby_versions.txt
   then
     printf "Your Ruby game is strong. Latest version $prefered_ruby_version confirmed\n"
     rm -f $TMPDIR/local_ruby_versions.txt 
  
  else
 	 printf "${Yel}required ruby version is not present in RVM\n${NoC}"
 	 printf "${Yel}Please install RVM ruby version: $acceptable or greater.\n${NoC}"
 	 exit
  fi
 }

check_gems(){

	 gem --version > $TMPDIR/local_gem_version.txt

	 local_gem_version="2.4"

 if grep -q $local_gem_version $TMPDIR/local_gem_version.txt
	 then
	 printf "Required Gem version $local_gem_version and greater confirmed as present on this machine\n"
	 rm -f $TMPDIR/local_gem_version.txt

 else 
	 printf "${Yel}Required gem version does not meet requirement. Running gem update NOW\n${NoC}"
	 gem update
	 gem cleanup
         printf "\n"
 fi
}


check_maven(){
  
         mvn -version > $TMPDIR/local_mvn_version.txt
  	 acceptable_mvn_version='3.1.1'
  	 preferred_mvn_version='3.2.'
   if grep -q $acceptable_mvn_version $TMPDIR/local_mvn_version.txt
	   then
   		printf "Acceptable Maven version $mvn_version and greater confirmed as present on this machine\n"
   		rm -f $TMPDIR/local_mvn_version.txt
        
   elif grep -q $preferred_mvn_version $TMPDIR/local_mvn_version.txt
 	  then
   		printf "Preferred Maven version $mvn_version and greater confirmed as present on this machine\n"
   		rm -f $TMPDIR/local_mvn_version.txt

   else
   		printf "${Yel}required mvn version does not meet requirement. Installing Maven for you!!\n${NoC}"
   		brew install maven
   fi
  }


check_xcode_version(){
    
    if [ -d  /Applications/Xcode.app ]; then
          cd /Applications/Xcode.app/Contents/Developer/usr/bin/

   	 ./xcodebuild -version > $TMPDIR/local_xcode_version.txt 
    else 
       printf "*****${Red} PLEASE INSTALL XCODE BEFORE RUNNING THIS PROGRAM ${NoC}**********"
       exit
    fi    
  	   acceptable_xcode_version='5.1'
   	   preferred_xcode_version='6.'
    
    if grep -q $acceptable_xcode_version $TMPDIR/local_xcode_version.txt
   	 then
    		printf "Acceptable Xcode version $acceptable_xcode_version and greater confirmed as present on this machine\n"
    		rm -f $TMPDIR/local_xcode_version.txt
   
    elif grep -q $preferred_xcode_version $TMPDIR/local_xcode_version.txt
  	  then
      		 printf "${Blue}Your Xcode game is strong. Xcode >6 is installed!\n${NoC}"

    else
  	  printf "${Red}required Xcode version does not meet requirement. Please install Xcode 6.0.1 and greater and then re-run this program\n${NoC}"
  	  exit
   
    fi
   
   }


install_appium_console(){
        gem uninstall -aIx appium_lib
        gem uninstall -aIx appium_console
	      gem install --no-rdoc --no-ri appium_console

}


check_path() {
   
   cat ~/.bashrc ~/.bash_profile > $TMPDIR/local_path_check.txt
   echo $verify_path
   if grep -q $verify_path $TMPDIR/local_path_check.txt
    then
      printf "PATH $verify_path successfully  added to Bash Profile\n"
      rm -f $TMPDIR/local_path_check.txt
    else
      printf "${Red}*** EXITING PATH CHECK*** Please verify $verify_path path in either your ~/.bashrc or ~/.bash_profile is correctly configured before contuniung\n${NoC}"
      rm -f $TMPDIR/local_path_check.txt
    exit
    fi
  }

init(){

	printf "============================= Checking for RVM ==============================================\n\n"
        	         check_rvm    
	        printf "***** Verifying PATH *****\n\n"
                         cd $HOME/.rvm/bin
                         verify_path=$(pwd)
                         check_path 
            		 printf "SUCCESS: RVM is correctly installed!\n" 

        printf "============================= Checking for Ruby Version =====================================\n\n"
                         check_ruby
                         printf "SUCCESS: Ruby is correctly installed!\n"

        printf "============================= Running Updates for RVM and Ruby ================================\n\n"
                                       update_rvm_ruby
                          printf "SUCCESS: RVM is on latest version\n"
}

gems(){
	printf "============================= Updating Ruby Gems  ==============================================\n\n"
                           gem update --system
                           gem install --no-rdoc --no-ri bundler
                           gem update
                           gem cleanup
                                          
                           printf "SUCCESS: Ruby Gems Installed! \n"

        printf "============================= Verifying Gem version ==============================================\n\n"
                           check_gems

       		 printf "***** Verifying PATH *****\n"
                           verify_path=$(which gem)
                           echo $verify_path
                           if [ -n $verify_path ]; then     
	                           printf "SUCCESS: Ruby Gem version up-to-date!\n"
                           else 
        	                   print "${Red}FAILURE: Gem path is missing. Please re-run program again\n${NoC}"
                           fi

         printf "============================= Installing Appium Specific Gem  ==============================================\n\n"
                           install_appium_console
		           verify_appium_gems=$(gem list | grep appium)
                           echo $verify_appium_gems
                           if [[ -n $verify_appium_gems ]]; then
                         	  printf "SUCCESS: Appium Console Gem version installed!\n"
                           else
                          	  printf "${Red}FAILURE: appiul_console and appium_lib gems might be missing. Please Verify by running ge list command\n${NoC}"
                           fi

         printf "============================= Installing Flanky Gem ==============================================\n\n"
                            gem uninstall -aIx flaky
                            gem install --no-rdoc --no-ri flaky
                            verify_flaky_gem=$(gem list | grep flaky)
                            if [ -n $verify_flaky_gem_gems ]; then
                          	   printf "SUCCESS: Flaky Gem version installed!\n"
                            else
                          	   printf "${Red}FAILURE: Flaky gem might be missing. Please Verify by running gem list command\n${NoC}"
                            fi
}



tools_and_systems(){

         printf "============================= Installing Brew  ==============================================\n\n"
                            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                            printf "SUCCESS: Brew Installed!\n"

         printf "============================= Installing NodeJS Using Brew  ==============================================\n\n"
                             brew update
                             brew upgrade node
                             brew install node
                 printf "***** Verifying PATH *****\n"
                             node --version
                             npm --version
                             verify_path='/usr/local/share/npm/bin/'
                             check_path
                             printf "SUCCESS: Node Installed!\n"

	printf "============================= CLONING APPIUM  ==========================================================\n\n"
                             printf "Installing appium in your home directory\n"
                             cd $HOME
                             if [ ! -d ~/appium ]; then
                             git clone https://github.com/appium/appium.git
                             printf "SUCCESS: Appium Installed\n"
                             else 
                             printf "You already have a directory called appium in your home folder. Please delete it or rename it for a fresh appium install. RE-RUN PROGRAM AFTER!\n"
                             fi

         printf "============================= Installing Grunt  ===============================================================\n\n"
                             cd $HOME/appium
                             npm install -g grunt grunt-cli

	         printf "***** Verifying PATH *****\n" 
                             grunt --version
                             verify_path='/usr/local/share/npm/bin/grunt'
                             check_path
                             printf "SUCCESS: Grunt Installed!\n"

         printf "============================= Installing ANT  ==================================================================\n\n"
                              brew install ant

		printf "***** Verifying PATH *****\n"
                              ant -version
                              verify_path='/usr/local/Cellar/ant/'
                              check_path
                              printf "SUCCESS: Ant Installed!\n"

         printf "============================= Verifying MAVEN  ==================================================================\n\n"
                              check_maven

		printf "***** Verifying PATH *****\n"
                              mvn -version
                              verify_path='/usr/local/apache-maven/apache-maven-'
                              check_path
                              
                              printf "SUCCESS: Maven version up-to-date!\n"

         printf "============================= Checking Xcode Version  ============================================================\n\n"
                               check_xcode_version
                               printf "SUCCESS: Xcode Verified!\n"

         printf "============================= Other missing folders and tools Install  ==============================================\n\n"
                               
                               printf "******* Installing APPLE GCC 42 *************\n\n"
                               brew install apple-gcc42
                               printf "******* Attempting Install Readline gem ******\n\n"
 
                               if  [ -d /usr/local/Cellar/readline ]; then                                  
                                gem install rb-readline
                               else 
                                 printf "You do not have the readline directory. Now creating it and installing rb-readline gem\n"
                              	 cd /usr/local/Cellar
                              	 mkdir readline
                              	 gem install rb-readline
                               fi

                               printf "******** Attmepting to install libyaml, openssl and libtool ******\n\n"
                               brew install libyaml
                               brew install openssl
                               brew install libtool

          printf "==================================== BUILD COMPLETE ==============================================================\n\n\n"

}


final_setup_ios(){

cd $HOME/appium

./reset.sh --ios --verbose

tput clear

printf "${Orange}************************************** NOW STARTING NODE SERVER *******************************************************************\n\n${NoC}"

node .

}

#################============================= Program STARTS HERE =============================#########################################

tput clear

rm -f $TMPDIR/local_path_check.txt

rm -f $TMPDIR/local_ruby_versions.txt

rm -f $TMPDIR/local_gem_version.txt

rm -f $TMPDIR/local_mvn_version.txt

rm -f $TMPDIR/local_xcode_version.txt

init

gems

tools_and_systems

final_setup_ios
