curl --progress-bar --connect-timeout 30 --junk-session-cookies --insecure --location --max-time 3600 --retry 3 --retry-delay 60 "http://bio3d.colorado.edu/imod/AMD64-RHEL5/imod_4.7.15_RHEL7-64_CUDA6.5.csh" --output "imod_4.7.15_RHEL7-64_CUDA6.5.csh"

yum install tcsh file libjpeg freetype libSM libXi libXrender libXrandr libXfixes libXcursor libXinerama fontconfig -y

mkdir imod
mkdir scripts
tcsh -f imod_4.7.15_RHEL7-64_CUDA6.5.csh -script scripts -dir imod -yes

