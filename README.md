# Introduction

This project serves two purposes

1. playground for me to learn ruby and git so that I can eventually play with http://pinocc.io/
2. Let me play with ideas for how we can integrate environment mangement with source management at expedia

# Promotion strategy

the driver behind this tool is that at Expedia we manage 4 environments that have to all be in sync
and we want to automate as much of this as we possibly can, and have that strategy always adhere 
to the principles of 

* always know what is on the live site
* always be able to change the live site
* always be able to test the live site

And then automate the shit out of all of that.

So the general idea here is that we promote our work like this

# Promotion path through environments

## dev -> trunk
develoeprs, when they are "done" with there work, will put it into the trunk environmetn, which
is a shared environmetn for the entire organization, and represents the latest work of all combined 
efforts.  The expectation here, is that everything should always be working in the trunk environment.

Applications in the trunk environment, tend to lean on dependencies hosted in the integration environment.

## trunk -> integration
The integration environment is for all of the n+1 versions of every component that we plan to deploy to the live
site.  All applicaitons are expected to be deployed shuntlessly to this environment, and take builds of what has been 
running in trunk that we now believe are "RC" ready.   There is no minumum required time that a component is 
expected to be in the integration envorinment before it is released, but it is intended that everything that is
deployed to the live environment, is working in an integrated manner in the integration environment

the integration environment should be self referential, and depend only on other components hosted in the integration
environments

## integration -> live
once a component has been proven to work in the integration, it is clear to be deployed to the live environment 
(coordination with CAB not withstanding)

Anything that is propped to the live environment is also expected to be deployed to the int-milan environment to 
support the possible need to hotfix the component, or other components that may depend on it.  

## int-milan -> live
if a component needs to be changed on the live site, but it is not possible to put test the new version in the 
integration environment for whatever reason, then the new version of the component, should be able to be propped
into the int-milan environment, verified, and then that version deployed to the live site.

# Managing required changes post promotion
"In theory there is no difference between theory and practice, in practice there is"
  - Yogi Berra

In a perfect world, every change we made to the trunk environment, would make it's way to the live site straight away
but in reality, we find that changes are made to the trunk environment more frequently then to the integration environmetn
and there may be times that there are changes on trunk that can't be promoted, yet there is a change that needs to be made
to the component running in the integration environment to make it suitable to ship too the live environment.

So we have to support the ability to make that change to the integration environment, and we would like to make sure
that it is also included in the trunk environment.  Preferbly this should be automated, so that no one has to think about it.

## Implicit integration
in the perfore world we use implicit integration to make sure that changes that are made to the components running in the 
integration environment are automatically integrated into the trunk environment.

## Magic Merges
In the git world, it is possible to also automagically merge changes that are made to the live environment into the integration 
environnent, and in the integration environment to the trunk environment.

Again, in the perfect world that we want to live in, we would never need to rely on this merge path, since all changes would
would only get to the live site by being deployed to trunk, then integration, and then to live, and then to hotfix.

# Builds
## Perforce - evolved from components
The build infrastructure that we have for components, evolved in the era of reresolving ivy with every build, and having
different resolver changes.  Which results in the deliverables of one build not being the same as the deliverables
of another build done from the same sources but at a different time.

Additionally - we used the branch name (which is the path to the collection of files in perforce) to provide meta data
to the buidl component about what it was.  Which turns out to be a material differnce (along with the CL) driving
us to a model where we rebuild upon promotion, which leads to redeploying, and reverification of the bits that are
created - this is antiagonistic to the goals of continuous deliver

Combine that with the fact that it is the combination of the path in perforce (actually the state of the view) and
the CL (and not even then at times, since your have list may not be any arbitrary state of perforce) leads 
to the situation where it becomes challenging to keep track of exactly the state of the files that went into 
any one build - there is a lot infrastruture in the world that was created to manage complexity.

## Git - something new think new
Every commit in git is unique, and if any two people can checkout the same commit hash, their workding directories will be 
identical.

Thee commit hash in git is globally unique forever.  Meaning no two commit hashes will collide in our, or our childrens
lifetimes.

This means that a build of a commit hash today, will create the same results as the build of that commit hash in the future
(dependncy resolution not withstanding, but we will address that)

So, what that means is that we only ever have to build any given commit once.  If we ever refer to that same commit hash
in the future, we can just use the bits that we have already created.  

### Merges in git
Git "branches" are really nothging but pointers to a particular commit hash in the DAG of commits.  If one commit can be reached 
by it's ancestor directly, then a branch pointing to grandchild can be merged into the branch pointing to the grandparent
using the 'fast forward' mechanism, which results in the branch that was pointing to the grandparent commit, now simply
points to the same commit as the granchild we merged it with.

### Implications of that for builds
This has an interesting affect. We have two branches pointing to the same commit.  We don't need to rebuild just because 
we have a new branch pointing to it.  Any thing that wants to prop builds of a branch, can just use the build results 
when the commit that the grand parent points to first showed up.

# Automated deployments
In the convoy world, deployments are tediously manual.  between creatign builds, updating DeploymentUnit files, running convoy o
on the target machine with the correct DeploymentUnit. Yech.

Not to mention that the efforts to automate this process as part of the CD pipeline are good, and they allow us to 
increase the velicuty and decrease the time it takes any change to get propped to an environment, it has 
lead to an increasingly wide delta between how things are deployed to the labs, and how they are deployed to the
live environment.  

## Jenkins vs Bladelogic
* wrapper scripts, override, and dvt's in jenkins
* collection of blade logic jobs that are under no form of source control, promotion, or sensical organization
* Different rotation strategies
* Different stacks

All of this leads us the the place where what happens in the lab is decreasing in it's abilithy to help us 
understand what is goign to happen in the live site.

Soaking has helped with this, but we need to come together, back to a unified approach.

## Proposal
I propose that we set up an automation infrastructure that will allow us to automate deployment of applications into 
one of the managed environments based on a mapping of 

git repo/branch within repo

so for example, the userinteraction component in the trunk environment, is deployed with the build that the trunk "branch" 
in the repository that creates the deployable components, points to.

When we change the commit that the branch points to, we automatically notice that, and redeploy the componetn to the 
trunk environment.

when we change the commit that the integration branch points to, we automatically deploy the component to the integration
environment.   Since we are promoting the trunk branch into the integration branch, we will be using the exact same build
deliverables for the deployment to the integration environment.

Same thing can apply to the live environment.

### Tagging
For the live site deployments I propose that we apply a tag of the format 

   rtw/yyyy/mm/dd/thh:mm:ss

to the commit that was deployed to the live environment.

### int-milan
Whenever the integraiton branch is promoted into the live branch, we would update the int-milan branch to point to the 
same commit.  This would drive an automated deployment of the int-milan environment  Making it always at the ready 
to host hotfix commits if neccesary to fix the live site.

### Automatic merges
Just like we currently have implicit integration for components hosted in perforce, we would set up an automatic
merge process.  

for every promotion path, we would inverse it, and say that changes on the superior branch are automatically merged
to the inferior branch, and submitted.  If there was a conflict, then the strategy would be much like we have
with implicit integraiton, and we would send a mail to the effected parties and ask them to resolve the conflict.
Once resovled, committed, and pushed, it would create a new build, that would be propped, and the cycle continues. 
 

[TODO] Make a perdy picture so no one has to read all of that
