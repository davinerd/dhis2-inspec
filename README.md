# What it is
This inspec profile helps in assessing the security configuration around DHIS2 deployments.

# How to use it

1. Clone the repository
```
$ git clone 
$ cd dhis2-inspec
```

2. Run the desired control. Pass the container name and the control you want to use
```
dhis2-inspec$ bash run_inspec.sh <container_name> controls/<control>.rb
```

# Examples
To assess the tomcat deployment, assuming you have a container named `dhis2`, you can use:
```
dhis2-inspec$ bash run_inspec.sh dhis2 controls/tomcat.rb
```
