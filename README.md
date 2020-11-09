# Freezaform
A terraform-based setup with a thin tool to set up different environments on a docker layer.

This projects is a small Proof of Concept on how to set up a terraform infrastructure.
The idea is taken from [1] and Terragrunt, but with an easier approach.

# Why
+ You can create a set of separated terraform modules called icicles (ghiaccioli in Italian).
+ Every icicle can be configured to work on a different configuration
+ Every configutation has its state file. You can export data in a icicle and read in another (see https://github.com/ozbillwang/terraform-best-practices#retrieve-state-meta-data-from-a-remote-backend )
+ We experienced some trouble with terrargunt (crash on windows and bugs) and we take a lighter approach. Also Freezaform depends only on bash and on terraform, and often bash is already installed (!)

The example is based on a docker provider for simplicity, but can be extended to support industrial grade cloud providers as well.

# How it works
First of all, the "freezer" command is responsible to create the correct terraform configuration, for a set of differente macro modules called "icicles".

Every icicle has a different state file and can be applied independently to others.

You can switch environment with 
 freezer <envname>

# Terragrunt

Terragrunt is a more deep solution but freezer is less invasive and simpler to understand.


# References
[1] https://github.com/ozbillwang/terraform-best-practices#manage-multiple-terraform-modules-and-environments-easily-with-terragrunt
