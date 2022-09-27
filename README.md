# Welcome to XYZ-DevSecOps! 
Gets let get right to it - while storing Infra configuration is a lot smarter then having them zipped and sent across manually, this messes up.
**"Special Snowflakes"** exist due to changes being made on Infra files in the main repos **which has a bunch of branches** - and there's been cases where it's been a hassle. Plus, this saves a lot of time for CD builds - you don't really need to clone the initial repo.

 - [x] Copy over Current Configuration from omnichannel-be
 - [ ] Make pipeline changes in original repo to clone this and have this script run for builds
