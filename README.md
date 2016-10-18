# GuardianRolesAuth

This is available for my own personal benefit.  It adds roles capabilities to Guardian, but I needed to put it into a separate library so I could use it in multiple services without duplicating code.

Currently, it has area's that reference my projects directly.  This isn't good for the public.  If anyone wants me to develop on this to make it a useful public tool, let me know :-)

The long and short of it is, it adds Groups to Users (in my case, sites).  This is a many-to-many relationship.  Each mapping is called a role and has an integer representation ranging from 0 to 100.  I do plan on ripping out chunks of code and converting to compile-time function generation based on the values in the config file, but I'll do it when I have time (along with removing direct project references).