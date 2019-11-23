---
title: "Golang Yaml to Json"
date: 2019-11-04T06:42:05-06:00
draft: true
---

Converting Yaml to Json is easy in Python, infact if we assume we have some common utilities to hand, then we can perform this in a single line:

```bash
pip install --user PyYAML
echo "foo: bar" | python -c 'import sys, yaml, json; variable=yaml.safe_load(sys.stdin.read()); print(json.dumps(variable))'
```

The above used to be one of my favorite questions to ask in an interview, and get a candiate to whiteboard. The problem itself is trivial, but provides a couple of great jumping off points to get into conversation:
 * What would you need to do to convert Json to Yaml? (And yes, this is essentialy a trick question)
 * Lets talk about dependency management
 * How could we add tests and CI to this?
etc.

But the world is changing around us. At my work we are move from being an OpenStack (and hence python) shop toward being a Kubernetes (and hence Golang) house, lets look at how we could solve this challenge with go. I hope that by doing so we can get a few things under our belt:
 * Bootstrapping a Golang project
 * Dependency management using Go Modules
 * Reading from stdin in Golang
 * The basics of structs and (un)marshaling

This example I think is also quite nice as it demonstrates, until someone points out I'm doing it all wrong, how sometimes the new hotness is not necessarily the right tool for the job, as we move from a single line solution to something much more complex to accomplish the same result.
