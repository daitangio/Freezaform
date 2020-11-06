# Freezaform
A terraform-based setup with a thin tool to set up different environments on a docker layer. A simpler terragrunt

This projects is a small Proof of Concept on how to set up a terraform infrastructure which can be sub configured on different environaments with little effort

The idea is taken from [1] and Terragrunt, but with an easier approach.
We experienced some toruble with terrargunt (crash on windows and bugs) and we take a lighter approach.

The example is based on a docker provider for simplicity, but can be extended to support inustrail grade cloud providers as well.

# How it works
First of all, the "freezer" command is responsible to create the correct terraform configuration, for a set of differente macro modules called "icicles".

Every icicle has a different state file and can be applied independently to others.

You can switch environment with 
 freezer <envname>

# Terragrunt

Terragrunt is a more deep solution but freezer is less invasive and simpler to understand.


# References
[1] https://github.com/ozbillwang/terraform-best-practices#retrieve-state-meta-data-from-a-remote-backend
