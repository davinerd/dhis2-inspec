# What it is
This inspec profile helps in assessing the security configuration around DHIS2 deployments.

# How to use it

1. Clone the repository
```
$ git clone https://github.com/davinerd/dhis2-inspec.git
$ cd dhis2-inspec
```

2. Install inspec (if running locally)
Please choose the method that works best for you here the [official documentation](https://docs.chef.io/inspec/install/)

3. Run the desired control
```
dhis2-inspec$ inspec exec controls/<control>.rb 
```

If you want to assess the deployment on an lxd container, use the `run_inspec.sh` script and pass the container name and the control you want to use
```
dhis2-inspec$ bash run_inspec.sh <container_name> controls/<control>.rb
```

# Examples
To assess the tomcat deployment on an lxd container, assuming you have a container named `dhis2`, you can use:
```
dhis2-inspec$ bash run_inspec.sh dhis2 controls/tomcat.rb
```
