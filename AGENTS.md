# The root of the inferno distribution
ROOT=/home/caerwyn/inferno64

# Build the proejct
`mk install`

# Compile an individual limbo file
`limbo file.b`

# Run an inferno .dis file produced by compiling a limbo file
`inferno  file.dis`

# Get documentation on a limbo module
```
inferno man sys   # inferno system calls
inferno man 2 string # string functions
```