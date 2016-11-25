# imod-docker
Docker image for running batchruntomo from [imod](http://bio3d.colorado.edu/imod/).

If you download imods [tutorial data](http://bio3d.colorado.edu/imod/files/tutorialData.tar.gz) and unzip it, then you can reconstruct it using the provided .adoc file as follows:  

docker run -v /tutorialData:/data -v /imod-docker:/scripts kevin/imod-centos batchruntomo --directive /scripts/directives.adoc

where the tutorialData and imod-docker paths are folders contained the data and the .adoc file respectively. 
