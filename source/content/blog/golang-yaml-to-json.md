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
 * What would you need to do to convert Json to Yaml?
 * Lets talk about dependency management
 * How could we add tests and CI to this?
etc.

But the world is changing around us.
